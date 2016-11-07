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
#include <stdlib.h>
#include <string.h>
#include <stdbool.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <cutils/properties.h>
#include <sys/mman.h>
#include <errno.h>
#include "edify/expr.h"
#include "error_code.h"

#define FORCE_RW_OPT            "0"
#define EMMC_SIZE               0x400000
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

static int write_raw_image(void *data, unsigned size, char *partition) {

    int fd = 0;
    char *ptr;

    fd = open(partition, O_RDWR);

    if (fd < 0) {
        fprintf(stderr, "write_bolt_emmc: faile to open %s\n", partition);
        goto err_partition;
    }

    ptr = (char *)mmap(NULL, EMMC_SIZE, PROT_READ|PROT_WRITE, MAP_SHARED, fd, 0);
    if (ptr == MAP_FAILED) {
        fprintf(stderr, "write_bolt_emmc: mmap failed on %s with error: %s\n", partition, strerror(errno));
        goto err_partition;
    }

    if (data != NULL) {
        memcpy(ptr, data, size);
    } else {
        fprintf(stderr, "write_bolt_emmc: no data given.\n");
        goto err_partition_copy;
    }

    munmap(ptr, EMMC_SIZE);
    close(fd);

    return 0;

err_partition_copy:
    munmap(ptr, EMMC_SIZE);

err_partition:
    close(fd);

    return -1;
}

static int write_gpt_emmc(void *data, unsigned size) {

    int emmc_index;
    bool found_gpt = false;
    char gpt_partition[FILE_PATH_SIZE] ;

    for (emmc_index = 0; emmc_index < 2; emmc_index++) {

        snprintf(gpt_partition, FILE_PATH_SIZE, "/dev/block/mmcblk%d", (1-emmc_index));

        if ( access( gpt_partition, F_OK ) != -1) {
            found_gpt = true;
            break;
        }
    }

    if (!found_gpt) {
        fprintf(stderr, "write_gpt_emmc: did not find gpt partition\n");
        return -1;
    }

    return write_raw_image(data, size, gpt_partition);
}

static int write_bolt_emmc(void *data, unsigned size) {

    int emmc_index;
    bool found_boot = false;
    char boot_partition[FILE_PATH_SIZE] ;
    char boot_partition_force_ro[FILE_PATH_SIZE];

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

    return write_raw_image(data, size, boot_partition);
}

Value* FlashBoltAvkoFn(const char *name, State *state, int argc, Expr * argv[]) {

    Value *ret = NULL;
    char *filename = NULL;
    unsigned char *buffer = NULL;
    int bolt_size;
    FILE *f = NULL;

    if (argc != 1) {
        ErrorAbort(state, kArgsParsingFailure, "%s() expected 1 arg, got %d", name, argc);
        return NULL;
    }

    if (ReadArgs(state, argv, 1, &filename) < 0) {
        ErrorAbort(state, kArgsParsingFailure, "%s() invalid args ", name);
        return NULL;
    }

    if (filename == NULL || strlen(filename) == 0) {
        ErrorAbort(state, kArgsParsingFailure, "filename argument to %s can't be empty", name);
        goto done;
    }

    if ((f = fopen(filename, "rb")) == NULL) {
        ErrorAbort(state, kFileOpenFailure, "Unable to open file %s: %s ", filename, strerror(errno));
        goto done;
    }

    fseek(f, 0, SEEK_END);
    bolt_size = ftell(f);
    if (bolt_size < 0) {
        ErrorAbort(state, kLseekFailure, "Unable to get bolt_size");
        goto done;
    }
    fseek(f, 0, SEEK_SET);

    if ((buffer = reinterpret_cast<unsigned char*>(malloc(bolt_size))) == NULL) {
        ErrorAbort(state, kVendorFailure, "Unable to alloc bolt flash buffer of size %d", bolt_size);
        goto done;
    }
    fread(buffer, bolt_size, 1, f);
    fclose(f);

    if (write_bolt_emmc(buffer, bolt_size) != 0 ) {
        ErrorAbort(state, kFwriteFailure, "Unable to flash bolt in emmc");
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

Value* FlashGPTAvkoFn(const char *name, State *state, int argc, Expr * argv[]) {

    Value *ret = NULL;
    char *filename = NULL;
    unsigned char *buffer = NULL;
    int gpt_size;
    FILE *f = NULL;

    if (argc != 1) {
        ErrorAbort(state, kArgsParsingFailure, "%s() expected 1 arg, got %d", name, argc);
        return NULL;
    }

    if (ReadArgs(state, argv, 1, &filename) < 0) {
        ErrorAbort(state, kArgsParsingFailure, "%s() invalid args ", name);
        return NULL;
    }

    if (filename == NULL || strlen(filename) == 0) {
        ErrorAbort(state, kArgsParsingFailure, "filename argument to %s can't be empty", name);
        goto done;
    }

    if ((f = fopen(filename, "rb")) == NULL) {
        ErrorAbort(state, kFileOpenFailure, "Unable to open file %s: %s ", filename, strerror(errno));
        goto done;
    }

    fseek(f, 0, SEEK_END);
    gpt_size = ftell(f);
    if (gpt_size < 0) {
        ErrorAbort(state, kLseekFailure, "Unable to get gpt_size");
        goto done;
    }
    fseek(f, 0, SEEK_SET);

    if ((buffer = reinterpret_cast<unsigned char*>(malloc(gpt_size))) == NULL) {
        ErrorAbort(state, kVendorFailure, "Unable to alloc gpt flash buffer of size %d", gpt_size);
        goto done;
    }
    fread(buffer, gpt_size, 1, f);
    fclose(f);

    if (write_gpt_emmc(buffer, gpt_size) != 0 ) {
        ErrorAbort(state, kFwriteFailure, "Unable to flash gpt in emmc");
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
    RegisterFunction("avko.flash_gpt", FlashGPTAvkoFn);
}
