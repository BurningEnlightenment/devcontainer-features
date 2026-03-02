#!/bin/bash
set -e

echo "Activating feature 'BurningEnlightenment/common-utils'"

FEATURE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

. "$FEATURE_DIR/versions"

download_dir=$(mktemp -d)
pushd "$download_dir"

install_debian_packages() {
    export DEBIAN_FRONTEND=noninteractive

    # install ripgrep
    curl -Lso ripgrep.deb "${rtool_ripgrep_base_url}/${rtool_ripgrep_deb_path}"
    echo "${rtool_ripgrep_deb_chksum}  ripgrep.deb" | sha256sum -c -
    dpkg -i ripgrep.deb
}

install_rhel_packages() {

    # install ripgrep
    if [[ "${ID}" -ne "fedora" ]]; then
        dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm
    fi
    dnf -y install "ripgrep"
}

install_alpine_packages() {

    #install ripgrep
    apk add --no-cache ripgrep
}

install_generic_rust_tools() {
    for rtool in "${rtools[@]}"; do
        local _version="rtool_${rtool}_version"
        local _libc_variant_vname="rtool_${rtool}_libc_variant"
        local _libc_variant="${!_libc_variant_vname:-${LIBC_VARIANT}}"
        local _base_url="rtool_${rtool}_base_url"
        local _chksum="rtool_${rtool}_${_libc_variant}_chksum"
        local _artifact_basename="${rtool}-${!_version}-x86_64-unknown-linux-${_libc_variant}"
        local _bin_path_vname="rtool_${rtool}_bin_path"
        local _bin_path="${!_bin_path_vname:-${_artifact_basename}/${rtool}}"
        curl -LOs "${!_base_url}/${!_version}/${_artifact_basename}.tar.gz"
        echo "${!_chksum}  ${_artifact_basename}.tar.gz" | sha256sum -c -
        tar -xf "${_artifact_basename}.tar.gz"
        mv "${_bin_path}" /usr/local/bin/
    done
}

install_ohmyposh() {
    local ohmyposh_bin="/usr/local/bin/oh-my-posh"
    curl -Lso "${ohmyposh_bin}" "https://cdn.ohmyposh.dev/releases/v${ohmyposh_version}/posh-linux-amd64"
    echo "${ohmyposh_chksum}  ${ohmyposh_bin}" | sha256sum -c -
    chmod +x "${ohmyposh_bin}"
    mkdir -p "/usr/local/share/oh-my-posh"
    cp -rf "$FEATURE_DIR/assets/themes" "/usr/local/share/oh-my-posh/themes"
}

install_zim() {
    local ZIM_HOME="${_REMOTE_USER_HOME}/.cache/zim"
    cp -f "$FEATURE_DIR/assets/.zshrc" "$_REMOTE_USER_HOME/.zshrc"
    curl --create-dirs -Lso ${ZIM_HOME}/zimfw.zsh "https://github.com/zimfw/zimfw/releases/download/v${zimfw_version}/zimfw.zsh"
    echo "${zimfw_chksum}  ${ZIM_HOME}/zimfw.zsh" | sha256sum -c -
    chown -R "${_REMOTE_USER}:${_REMOTE_USER}" "${ZIM_HOME}"
}

LIBC_VARIANT="gnu"

# Bring in ID, ID_LIKE, VERSION_ID, VERSION_CODENAME
. /etc/os-release
# Get an adjusted ID independent of distro variants
if [[ "${ID}" = "debian" || "${ID_LIKE}" = "debian" ]]; then
    ADJUSTED_ID="debian"
elif [[ "${ID}" = "rhel" || "${ID}" = "fedora" || "${ID}" = "azurelinux" || "${ID}" = "mariner" || "${ID_LIKE}" = *"rhel"* || "${ID_LIKE}" = *"fedora"* || "${ID_LIKE}" = *"mariner"* ]]; then
    ADJUSTED_ID="rhel"
    VERSION_CODENAME="${ID}${VERSION_ID}"
elif [[ "${ID}" = "alpine" ]]; then
    ADJUSTED_ID="alpine"
    LIBC_VARIANT="musl"
else
    echo "Linux distro ${ID} not supported."
    exit 1
fi

# Install packages for appropriate OS
case "${ADJUSTED_ID}" in
    "debian")
        install_debian_packages
        ;;
    "rhel")
        install_rhel_packages
        ;;
    "alpine")
        install_alpine_packages
        ;;
esac

install_generic_rust_tools
install_ohmyposh

popd

install_zim
