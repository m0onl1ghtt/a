#!/usr/bin/env bash
# vim: expandtab tabstop=4 shiftwidth=4

FILEPATH=$(readlink -f "$0")
DIRPATH=$(dirname "$FILEPATH")
export DIRPATH
export KERNEL_ROOT="$(pwd)"
export ARCH=arm64
export KBUILD_BUILD_USER="@nguyencaoantuong"
"$KERNEL_ROOT"="$DIRPATH/ks"
# Initial startup
mkdir -p "${HOME}/toolchains" "${KERNEL_ROOT}/out"
cd "$DIRPATH"
. common.sh
COMMIT="$(git rev-parse --short HEAD)"
BRANCH="$(git rev-parse --abbrev-ref HEAD)"

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
    esac
}

build() {
cd "${KERNEL_ROOT}"

export CROSS_COMPILE=$HOME/zyc-clang/bin/aarch64-linux-gnu-
export LD=$HOME/zyc-clang/bin/ld.lld
export OBJCOPY=$HOME/zyc-clang/bin/llvm-objcopy
export AS=$HOME/zyc-clang/bin/llvm-as
export NM=$HOME/zyc-clang/bin/llvm-nm
export STRIP=$HOME/zyc-clang/bin/llvm-strip
export OBJDUMP=$HOME/zyc-clang/bin/llvm-objdump
export READELF=$HOME/zyc-clang/bin/llvm-readelf
export CC=$HOME/zyc-clang/bin/clang
export CROSS_COMPILE_ARM32=$HOME/zyc-clang/bin/arm-linux-gnueabi-
export ARCH=arm64
export ANDROID_MAJOR_VERSION=r

export KCFLAGS=' -w -pipe -O3'
export KCPPFLAGS=' -O3'
export CONFIG_SECTION_MISMATCH_WARN_ONLY=y

"$KERNEL_ROOT"="$DIRPATH/ks"
    info "BUILD STARTED...!"
    echo "Use NO KernelSU defconfig as default! If u want to change, please kill script (Ctrl + C/Z) and change it."
    make -C $(pwd) O=$(pwd)/out KCFLAGS=' -w -pipe -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y clean -j$(nproc) && make -C $(pwd) O=$(pwd)/out KCFLAGS='-w -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y mrproper -j$(nproc)
    clear
    make -C $(pwd) O=$(pwd)/out KCFLAGS=' -w -pipe -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc) a32_noksu_defconfig
    make -C $(pwd) O=$(pwd)/out KCFLAGS=' -w -pipe -O3' CONFIG_SECTION_MISMATCH_WARN_ONLY=y -j$(nproc)

    cp "${KERNEL_ROOT}/out/arch/arm64/boot/Image" "${KERNEL_ROOT}/build"

    info "BUILD FINISHED..!"
    info "OUTPUT FILE IN: build folder!"
clear
}

tc() {
    info "Cloning zyc-clang version 14..."
    cd $HOME
    git clone https://github.com/EmanuelCN/zyc_clang-14 zyc-clang
    cd "$DIRPATH"
}

pull() {
git pull origin main
}

clear
# Banner
$FIGLET "a"
echo -------------------------------------------------------------
echo "A script for build kernel"
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
select opt in 'Pull latest commit' 'Clone latest kernel source' 'Add KernelSU' 'Hook' 'Install dependencies' 'Clone toolchains' 'Build' 'Exit'
do
    case "$opt" in
        'Clone latest kernel source' )   helium ;;
        'Pull latest commit' )   pull ;;
        'Add KernelSU' )   ksu ;;
        'Hook' )   hook ;;
        'Install dependencies' )   dependencies ;;
        'Build' )   build ;;
        'Clone toolchains' )   tc ;;
        'Exit' ) exit
    esac
done
