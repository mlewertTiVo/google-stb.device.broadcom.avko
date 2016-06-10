# Brcm DHD related defines
BRCM_DHD_PATH       := ${BRCM_NEXUS_INSTALL_PATH}/brcm_dhd
BRCM_DHD_KO_NAME    := bcmdhd.ko
BRCM_DHD_FW_NAME    ?= pcie-ag-pktctx-splitrx-amsdutx-txbf-p2p-mchan-idauth-idsup-tdls-mfp-sr-proptxstatus-pktfilter-wowlpf-ampduhostreorder-keepalive-wfds-bdo-ak.bin
BRCM_DHD_NVRAM_DIR  ?= ${BROADCOM_DHD_SOURCE_PATH}/nvrams
BRCM_DHD_NVRAM_NAME ?= bcm43570.nvm

${B_DHD_OBJ_ROOT}:
	mkdir -p ${B_DHD_OBJ_ROOT}

${B_DHD_OBJ_ROOT}/driver/bcmdhd.ko: build_kernel ${B_DHD_OBJ_ROOT}
	cp -faR ${BROADCOM_DHD_SOURCE_PATH}/dhd ${B_DHD_OBJ_ROOT} && cp ${BROADCOM_DHD_SOURCE_PATH}/*.sh ${B_DHD_OBJ_ROOT}
	+cd ${B_DHD_OBJ_ROOT} && source ./setenv-android-stb7445.sh ${BROADCOM_WIFI_CHIPSET} && ./bfd-drv-cfg80211.sh

${B_DHD_OBJ_ROOT}/fw.bin.trx: ${BROADCOM_DHD_SOURCE_PATH}/firmware/${BROADCOM_WIFI_CHIPSET}-roml/${BRCM_DHD_FW_NAME} ${B_DHD_OBJ_ROOT}
	cp -p $< $@

${B_DHD_OBJ_ROOT}/nvm.txt: ${BRCM_DHD_NVRAM_DIR}/${BRCM_DHD_NVRAM_NAME} ${B_DHD_OBJ_ROOT}
	cp -p $< $@

.PHONY: brcm_dhd_driver
brcm_dhd_driver: ${BRCM_DHD_DRIVER_TARGETS}
	@echo "'brcm_dhd_driver' targets: ${BRCM_DHD_DRIVER_TARGETS}"

.PHONY: clean_brcm_dhd_driver
clean_brcm_dhd_driver:
	@if [ -d "${B_DHD_OBJ_ROOT}" ]; then \
		rm -rf ${B_DHD_OBJ_ROOT}; \
	fi
