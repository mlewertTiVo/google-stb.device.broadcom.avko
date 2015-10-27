/*
 * Copyright (C) 2009 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

#include <stdio.h>
#include <unistd.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <cutils/properties.h>
#include <sys/mman.h>
#include "edify/expr.h"
#include <errno.h>

#define FORCE_RW_OPT            "0"
#define EMMC_BOOT_SIZE          0x400000
#define FILE_PATH_SIZE          64

static int force_rw(char *name) {
    int ret, fd;

    fd = open(name, O_WRONLY);
    if (fd < 0) {
        fprintf(stderr, "force_ro(): failed to open %s\n", name);
        return fd;
    }

    ret = write(fd, FORCE_RW_OPT, sizeof(FORCE_RW_OPT));
    if (ret <= 0) {
        fprintf(stderr, "force_ro(): failed to write %s\n", name);
        close(fd);
        return ret;
    }

    close(fd);
    return 0;
}

static int write_bolt_emmc(void *data, unsigned size) {

    int boot_fd = 0;
    int emmc_index;
    bool found_boot = false;
    char boot_partition[FILE_PATH_SIZE] ;
    char boot_partition_force_ro[FILE_PATH_SIZE];
    char *ptr;

    for (emmc_index = 0; emmc_index < 2; emmc_index++) {

        snprintf(boot_partition, FILE_PATH_SIZE, "/dev/block/mmcblk%dboot0", emmc_index);
        snprintf(boot_partition_force_ro, FILE_PATH_SIZE, "/sys/block/mmcblk%dboot0/force_ro", emmc_index);

        if (force_rw(boot_partition_force_ro)) {
            fprintf(stderr, "write_bolt_emmc: failed to clear force_ro to mmc%d, trying next mmc block\n", emmc_index);
        } else {
            found_boot = true;
            break;
        }
    }

    if (!found_boot) {
        fprintf(stderr, "write_bolt_emmc: failed to clear force_ro to both mmc blocks\n");
        return -1;
    }

    boot_fd = open(boot_partition, O_RDWR);

    if (boot_fd < 0) {
        fprintf(stderr, "write_bolt_emmc: faile to open %s\n", boot_partition);
        goto err_boot;
    }

    ptr = (char *)mmap(NULL, EMMC_BOOT_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, boot_fd, 0);
    if (ptr == MAP_FAILED) {
        fprintf(stderr, "write_bolt_emmc: mmap failed on %s with error: %s\n", boot_partition, strerror(errno));
        goto err_boot;
    }

    if (data != NULL) {
        memcpy(ptr, data, size);
    } else {
        fprintf(stderr, "write_bolt_emmc: no data given.\n");
        goto err_boot_copy;
    }

    munmap(ptr, EMMC_BOOT_SIZE);
    close(boot_fd);

    return 0;

err_boot_copy:
    munmap(ptr, EMMC_BOOT_SIZE);

err_boot:
    close(boot_fd);

    return -1;
}

Value* FlashBoltAvkoFn(const char *name, State *state, int argc, Expr * argv[]) {

    Value *ret = NULL;
    char *filename = NULL;
    unsigned char *buffer = NULL;
    int bolt_size;
    FILE *f = NULL;

    if (argc != 1) {
        ErrorAbort(state, "%s() expected 1 arg, got %d", name, argc);
        return NULL;
    }

    if (ReadArgs(state, argv, 1, &filename) < 0) {
        ErrorAbort(state, "%s() invalid args ", name);
        return NULL;
    }

    if (filename == NULL || strlen(filename) == 0) {
        ErrorAbort(state, "filename argument to %s can't be empty", name);
        goto done;
    }

    if ((f = fopen(filename, "rb")) == NULL) {
        ErrorAbort(state, "Unable to open file %s: %s ", filename, strerror(errno));
        goto done;
    }

    fseek(f, 0, SEEK_END);
    bolt_size = ftell(f);
    if (bolt_size < 0) {
        ErrorAbort(state, "Unable to get bolt_size");
        goto done;
    }
    fseek(f, 0, SEEK_SET);

    if ((buffer = malloc(bolt_size)) == NULL) {
        ErrorAbort(state, "Unable to alloc bolt flash buffer of size %d", bolt_size);
        goto done;
    }
    fread(buffer, bolt_size, 1, f);
    fclose(f);

    if (write_bolt_emmc(buffer, bolt_size) != 0 ) {
        ErrorAbort(state, "Unable to flash bolt in emmc");
        free(buffer);
        goto done;
    }

    free(buffer);
    ret = StringValue(strdup(""));

done:
    if (filename)
        free(filename);

    return ret;
}

void Register_librecovery_updater_avko() {

    fprintf(stderr, "installing avko updater extensions\n");

    RegisterFunction("avko.flash_bolt", FlashBoltAvkoFn);
}
