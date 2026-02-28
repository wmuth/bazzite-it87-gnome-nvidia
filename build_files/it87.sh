#!/bin/bash
set -e

KERNEL_VERSION=$(rpm -q kernel-devel --queryformat '%{VERSION}-%{RELEASE}.%{ARCH}')
KERNEL_DIR="/usr/src/kernels/${KERNEL_VERSION}"

git clone https://github.com/frankcrawford/it87.git
cd it87
git switch h2ram-mmio

make -C "${KERNEL_DIR}" M=$(pwd) modules

${KERNEL_DIR}/scripts/sign-file sha256 /run/secrets/MOK /ctx/MOK.der ./it87.ko

mkdir -p /lib/modules/${KERNEL_VERSION}/kernel/drivers/hwmon
cp it87.ko /lib/modules/${KERNEL_VERSION}/kernel/drivers/hwmon/
depmod -a -F /proc/kallsyms "${KERNEL_VERSION}"

echo "it87" > /etc/modules-load.d/it87.conf
echo "options it87 mmio=1" > /etc/modprobe.d/it87.conf
