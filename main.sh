#!/usr/bin/env bash
# vim: expandtab tabstop=4 shiftwidth=4

FILEPATH=$(readlink -f "$0")
DIRPATH=$(dirname "$FILEPATH")
export DIRPATH
export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export KBUILD_BUILD_USER="@nguyencaoantuong"

# Initial startup
cd "$DIRPATH"

# Check if user is running on an actual Linux environment
if uname -a | grep -i Linux ; then
    info "You have Linux environment :)"
fi

# Check if figlet exists or not
if command -v figlet ; then
    FIGLET=figlet
else
    warn "figlet not found, ignoring banner !"
    FIGLET=:
fi


# Check if wget exists
if ! wget --version ; then
    err "wget not found !!!"
    info "Please install wget for your Linux distribution !"
    exit 127
fi

# Check if wget exists
if ! curl --version ; then
    err "wget not found !!!"
    info "Please install curl for your Linux distribution !"
    exit 127
fi

# Check if wget exists
if ! patch --version ; then
    err "patch not found !!!"
    info "Please install patch for your Linux distribution !"
    exit 127
fi

helium() {
    info "Cloning latest helium kernel source..."
    git clone https://github.com/HeliumKA/helium ks
    info "Done!"
}

ksu() {
    echo "-------------------------------------------"
    echo "Choose KernelSU variant."
    echo "1) KernelSU (v1.0.1)"
    echo "2) KernelSU Next (latest | nongki)"
    echo "3) RKSU (latest | nongki)"
    echo "4) MKSU (latest | nongki)"
    echo "5) WildSU (latest | nongki)"
    echo "6) CloudSU (latest | nongki)"
    echo "7) SukiSU Ultra (latest | nongki)"
    read -rp "Choose [1-7]: " choice

    case "$choice" in
        1)
            info "Adding..."
            cd "$DIRPATH/ks"
            curl -LSs "https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh" | bash -s v1.0.1
            ;;
        2)
            info "Adding..." 
            cd "$DIRPATH/ks"
            curl -LSs "https://raw.githubusercontent.com/KernelSU-Next/KernelSU-Next/next/kernel/setup.sh" | bash -
            ;;
        3)
            info "Adding..." 
            cd "$DIRPATH/ks"
            curl -LSs "https://raw.githubusercontent.com/rsuntk/KernelSU/main/kernel/setup.sh" | bash -s main
            ;;
        4)
            info "Adding..." 
            echo "Soon!"
            return 1
            ;;
        5)
            info "Adding..." 
            cd "$DIRPATH/ks"
            curl -LSs "https://raw.githubusercontent.com/WildKernels/Wild_KSU/wild/kernel/setup.sh" | bash -s wild
            ;;
        6)
            info "Adding..." 
            cd "$DIRPATH/ks"
            curl -LSs "https://raw.githubusercontent.com/KOWX712/KernelSU/kernel/setup.sh" | bash -s master
            ;;
        7)
            info "Adding..." 
            cd "$DIRPATH/ks"
            curl -LSs "https://raw.githubusercontent.com/SukiSU-Ultra/SukiSU-Ultra/main/kernel/setup.sh" | bash -s nongki
            ;;
        *)
            err "Invaild, exiting"
            return 1
            ;;
    esac

    
    info "Add done!"
}

hook() {
    echo "-------------------------------------------"
    echo "Choose hook support for your KernelSU variant added."
    echo "1) KernelSU hook"
    echo "2) SukiSU Ultra hook"
    read -rp "Choose [1-2]: " choice

    case "$choice" in
        1)
            info "Hooking..." 
            cd "$DIRPATH/ks"
            wget https://github.com/rsuntkOrgs/KSU-Hook/raw/refs/heads/master/4.14.diff
            patch -p1 < 4.14.diff
            rm -rf 4.14.diff
            info "Hook done!"
            ;;
        2)
            info "Hooking..." 
            cd "$DIRPATH/ks"
            wget https://github.com/HeliumKA/requiredthingsforscript/raw/refs/heads/main/sukisu.diff
            patch -p1 < sukisu.diff
            wget https://github.com/HeliumKA/requiredthingsforscript/raw/refs/heads/main/ms.diff
            patch -p1 < ms.diff
            rm -rf sukisu.diff; rm -rf ms.diff
            info "Hook done!"
            ;;
        *)
            err "Invaild, exiting"
            return 1
            ;;
    esac
}

dependencies() {
"$KERNEL_ROOT"="$DIRPATH/ks"
    echo "-------------------------------------------"
    echo "Choose distro are you in."
    echo "1) Fedora"
    echo "2) Debian/Ubuntu"
    echo "3) Arch"
    read -rp "Choose [1-2]: " choice

    case "$choice" in
        1)
            info "Installing...:"
            sudo dnf group install "c-development" "development-tools" && \
            sudo dnf install -y dtc lz4 xz zlib-devel java-latest-openjdk-devel python3 \
            p7zip p7zip-plugins android-tools erofs-utils \
            ncurses-devel libX11-devel readline-devel mesa-libGL-devel python3-markdown \
            libxml2 libxslt dos2unix kmod openssl elfutils-libelf-devel dwarves \
            openssl-devel libarchive zstd rsync libyaml-devel openssl-devel-engine --skip-unavailable
            ;;
        2)
            info "Installing..."  
            sudo apt update && sudo apt install -y git device-tree-compiler lz4 xz-utils zlib1g-dev openjdk-17-jdk gcc g++ python3 python-is-python3 p7zip-full android-sdk-libsparse-utils erofs-utils \
            default-jdk git gnupg flex bison gperf build-essential zip curl libc6-dev libncurses-dev libx11-dev libreadline-dev libgl1 libgl1-mesa-dev \
            python3 make sudo gcc g++ bc grep tofrodos python3-markdown libxml2-utils xsltproc zlib1g-dev python-is-python3 libc6-dev libtinfo6 \
            make repo cpio kmod openssl libelf-dev pahole libssl-dev libarchive-tools zstd libyaml-dev --fix-missing && wget http://security.ubuntu.com/ubuntu/pool/universe/n/ncurses/libtinfo5_6.3-2ubuntu0.1_amd64.deb && sudo dpkg -i libtinfo5_6.3-2ubuntu0.1_amd64.deb
            ;;
        3)
            info "Installing..."
            sudo pacman -Syu --needed base-devel git lz4 xz zlib gcc python python-setuptools p7zip android-tools erofs-utils \
            ncurses libx11 readline mesa libgl python-markdown libxml2 libxslt dos2unix kmod openssl elfutils dwarves \
            libarchive zstd rsync libyaml --noconfirm
            yay -S android-tools dtc jdk-openjdk dwarves
            ;;
        *)
            err "Invaild, exiting"
            return 1
            ;;
        info "Done! Downloading toolchains..."
        mkdir -p "${HOME}/toolchains" "${KERNEL_ROOT}/out"
        if [ ! -d "${HOME}/toolchains/clang-r383902b" ]; then
    echo -e "\n[INFO] Cloning clang-r383902b...\n"
    mkdir -p "${HOME}/toolchains/clang-r383902b" && cd "${HOME}/toolchains/clang-r383902b"
    curl -LO "https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/0e9e7035bf8ad42437c6156e5950eab13655b26c/clang-r383902b.tar.gz"
    tar -xf clang-r383902b.tar.gz && rm clang-r383902b.tar.gz
    cd "${KERNEL_ROOT}"
fi

if [ ! -d "${HOME}/toolchains/gcc" ]; then
    echo -e "\n[INFO] Cloning ARM GNU Toolchain\n"
    mkdir -p "${HOME}/toolchains/gcc" && cd "${HOME}/toolchains/gcc"
    curl -LO "https://developer.arm.com/-/media/Files/downloads/gnu/14.2.rel1/binrel/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz"
    tar -xf arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu.tar.xz
    cd "${KERNEL_ROOT}"
fi

export PATH="${HOME}/toolchains/clang-r383902b/bin:${PATH}"
export LD_LIBRARY_PATH="${HOME}/toolchains/clang-r383902b/lib:${HOME}/toolchains/clang-r383902b/lib64:${LD_LIBRARY_PATH}"

export BUILD_CROSS_COMPILE="${HOME}/toolchains/gcc/arm-gnu-toolchain-14.2.rel1-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-"
export BUILD_CC="${HOME}/toolchains/clang-r383902b/bin/clang"

export BUILD_OPTIONS=(
    HOSTLDLIBS="-lyaml"
    -C "${KERNEL_ROOT}"
    O="${KERNEL_ROOT}/out"
    -j"$(nproc)"
    ARCH=arm64
    CROSS_COMPILE="${BUILD_CROSS_COMPILE}"
    CC="${BUILD_CC}"
    CLANG_TRIPLE=aarch64-linux-gnu-
)
    esac
}

build() {
"$KERNEL_ROOT"="$DIRPATH/ks"
    info "BUILD STARTED...!"
    echo "Use NO KernelSU defconfig as default! If u want to change, please kill script and change it."
    make "${BUILD_OPTIONS[@]}" a32_noksu_defconfig
    echo "Executing the menu config..."
    make "${BUILD_OPTIONS[@]}" menuconfig
    echo "Build image started."
    make "${BUILD_OPTIONS[@]}" Image || exit 1

    cp "${KERNEL_ROOT}/out/arch/arm64/boot/Image" "${KERNEL_ROOT}/build"

    info "BUILD FINISHED..!"
    info "OUTPUT FILE IN: build folder!"

COMMIT="$(git rev-parse --short HEAD)"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"
clear
}

# Banner
$FIGLET "helium"
echo -------------------------------------------------------------
echo "A script for build helium kernel"
echo ------------------------------------------------------------
echo "Current commit : $COMMIT ($BRANCH)"
echo "Base this script from: https://git.disroot.org/mbcp/mbbpatch.git"
echo -------------------------------------------------------------

# Check if user runs on Termux
if [[ -f /data/data/com.termux/files/usr/bin/termux-setup-storage ]]; then
    warn "Termux environment detected !"
    warn "Script continue to runs, but some function will not work with Termux!"
fi
# Check if user runs on macOS environment
if [[ $OSTYPE == 'darwin'* ]]; then
    warn "macOS environment detected !"
    warn "Script continue to runs, but some function will not work with macOS!"
fi

# Main functions
PS3='Please select options to continue : '
select opt in 'Clone Latest helium kernel source' 'Add KernelSU' 'Hook' 'Install dependencies' 'Exit'
do
    case "$opt" in
        'Clone latest helium kernel source' )   helium ;;
        'Add KernelSU'  ksu ;;
        'Hook'   hook ;;
        'Install dependencies'  dependencies ;;
        'Build'  build ;;
        'Exit' ) exit
    esac
done
