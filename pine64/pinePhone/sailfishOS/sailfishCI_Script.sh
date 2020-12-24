#!/bin/bash

VERSION="0.3.2"
BRANCH=master
CUSTOM=""
UBOOT_JOB=u-boot
UBOOT_DIR=u-boot-bootloader

ROOTFS_PINEPHONE_1_0_JOB=pinephone-1.0-rootfs
ROOTFS_PINEPHONE_1_1_JOB=pinephone-1.1-rootfs
ROOTFS_PINETAB_JOB=pinetab-rootfs
ROOTFS_PINETABDEV_JOB=pinetab-rootfs
ROOTFS_DEVKIT_JOB=devkit-rootfs
ROOTFS_PINEPHONE_1_0_DIR=pinephone-1.0
ROOTFS_PINEPHONE_1_1_DIR=pinephone-1.1
ROOTFS_PINETAB_DIR=pinetab
ROOTFS_PINETABDEV_DIR=pinetab
ROOTFS_DEVKIT_DIR=devkit

UBOOT_PINEPHONE_1_0_DIR=pinephone-1.0
UBOOT_PINEPHONE_1_1_DIR=pinephone-1.1
UBOOT_PINETAB_DIR=pinetab
UBOOT_PINETABDEV_DIR=pinetabdev
UBOOT_DEVKIT_DIR=devkit

MOUNT_DATA=./data
MOUNT_BOOT=./boot

# Parse arguments
# https://stackoverflow.com/questions/192249/how-do-i-parse-command-line-arguments-in-bash
POSITIONAL=()
while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    -b|--branch)
        BRANCH="$2"
        shift
        shift
        ;;
    -h|--help)
        echo "Sailfish OS flashing script for Pine64 devices"
        echo ""
        printf '%s\n' \
               "This script will download the latest Sailfish OS image for the Pine" \
               "Phone, Pine Phone dev kit, or Pine Tab. It requires that you have a" \
               "micro SD card inserted into the computer." \
               "" \
               "usage: flash-it.sh [-b BRANCH]" \
               "" \
               "Options:" \
               "" \
               "	-c, --custom		Install from custom dir. Just put you rootfs.tar.bz2" \
               "				and u-boot-sunxi-with-spl.bin into dir and system will "\
               "				istalled from it" \
               "	-b, --branch BRANCH	Download images from a specific Git branch." \
               "	-h, --help		Print this help and exit." \
               "" \
               "This command requires: parted, sudo, wget, tar, unzip, lsblk," \
               "mkfs.ext4." \
               ""\
               "Some distros do not have parted on the PATH. If necessary, add" \
               "parted to the PATH before running the script."

        exit 0
        shift
        ;;
	-c|--custom)
		CUSTOM="$2"
		shift
		shift
		;;
    *) # unknown argument
        POSITIONAL+=("$1") # save it in an array for later
        shift # past argument
        ;;
esac
done
set -- "${POSITIONAL[@]}" # restore positional parameters

# Helper functions
# Error out if the given command is not found on the PATH.
function check_dependency {
    dependency=$1
    command -v $dependency >/dev/null 2>&1 || {
        echo >&2 "${dependency} not found. Please make sure it is installed and on your PATH."; exit 1;
    }
}