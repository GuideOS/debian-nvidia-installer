#!/usr/bin/env bash

# debian-nvidia-installer - NVIDIA Driver Installer for Debian (TUI)
# Copyright (C) 2025 Leonardo Amaral
#
# This file is part of debian-nvidia-installer.
#
# debian-nvidia-installer is free software: you can redistribute it and/or
# modify it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# debian-nvidia-installer is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with debian-nvidia-installer. If not, see <https://www.gnu.org/licenses/gpl-3.0.html>.

declare -Ag CUDA_DRIVER_VERSIONS=(
    ["latest"]="580"
    ["stable"]="575"
)

cudarepo::install_driver() {
    local key="$1"
    local flavor="$2"
    local version lock

    # Constrói as variáveis
    if [[ -v CUDA_DRIVER_VERSIONS["$key"] ]]; then
        version="${CUDA_DRIVER_VERSIONS[$key]}"
        lock="${version}.*"
    else
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Verifica se o usuário quer continuar
    if ! tui::yesno::default "$(tr::t "default.tui.title.warn")" "$(tr::t_args "cudarepo::install_driver.confirm" "$version" "$flavor")"; then
        log::info "$(tr::t "default.script.canceled.byuser")"
        return 255
    fi

    # Trava a versão caso a versão não seja a latest
    if [[ "$key" != "latest" ]]; then
        cudarepo::lock_cuda_version "$lock"
    fi

    # Instala o repositório CUDA
    if ! cudarepo::install_cuda_repository; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Instala o flavor escolhido
    local status
    case "$flavor" in
        open-source)
            cudarepo::install_cuda_opensource
            status=$?
            ;;
        proprietary)
            cudarepo::install_cuda_proprietary
            status=$?
            ;;
        *)
            log::critical "$(tr::t_args "cudarepo::install_driver.invalid_flavor" "$flavor")"
            log::input _ "$(tr::t "default.script.pause")"
            return 1
            ;;
    esac

    if [ "$status" -ne 0 ]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi
}

tr::add "pt_BR" "cudarepo::install_driver.confirm" "Você está prestes a instalar o driver %1-%2 fornecido pelo repositório CUDA.\n\nDeseja continuar?"
tr::add "pt_BR" "cudarepo::install_driver.invalid_flavor" "Ocorreu um erro inesperado: flavor %1 do driver não é reconhecido pelo script."

tr::add "en_US" "cudarepo::install_driver.confirm" "You are about to install the %1-%2 driver provided by the CUDA repository.\n\nDo you want to continue?"
tr::add "en_US" "cudarepo::install_driver.invalid_flavor" "An unexpected error occurred: driver flavor %1 is not recognized by the script."

cudarepo::install_cuda_repository() {
    local temp_download_file="/tmp/cudakeyring.deb"
    trap 'rm -f "$temp_download_file"' RETURN

    # Faz o download instalador do repositório CUDA
    wget -O "$temp_download_file" https://developer.download.nvidia.com/compute/cuda/repos/debian12/x86_64/cuda-keyring_1.1-1_all.deb | tee -a /dev/fd/3 
    if [[ "${PIPESTATUS[0]}" -ne 0 ]]; then
        log::critical "$(tr::t "cudarepo::install_cuda_repository.download_failure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Executa o instalador do repositório CUDA
    if ! packages::install "$temp_download_file"; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    # Atualiza a lista de pacotes depois de adicionar o novo repositório CUDA
    if ! packages::update; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi
}

tr::add "pt_BR" "cudarepo::install_cuda_repository.download_failure" "Falha no download do pacote de instalação do repositório CUDA. Operação abortada."

tr::add "en_US" "cudarepo::install_cuda_repository.download_failure" "Failed to download the CUDA repository installation package. Operation aborted."

cudarepo::uninstall_cuda_repository() {
    # Desinstala o pacote de instalação do repositório CUDA
    local rm_status
    if ! packages::purge "cuda-keyring"; then
        rm_status="$?"

        if ! [[ "$rm_status" =~ ^(0|100)$ ]]; then
            log::critical "$(tr::t_args "cudarepo::uninstall_cuda_repository.remove_failure" "$rm_status")"
            return 1
        fi

        log::info "$(tr::t "cudarepo::uninstall_cuda_repository.not_installed")"
    else
        log::info "$(tr::t "cudarepo::uninstall_cuda_repository.removed")"
    fi

    # Procura o arquivo do repositório CUDA para a arquitetura atual
    # log::info "$(tr::t "cudarepo::uninstall_cuda_repository.removing_sources")"

    # local dir="/etc/apt/sources.list.d"
    # local file
    # file="$(find "$dir" -maxdepth 1 -type f -name "cuda-*$(uname -m).list" | head -n1)"

    # if [[ -n "$file" ]]; then
    #     sudo rm -f "$file"
    #     log::info "$(tr::t_args "cudarepo::uninstall_cuda_repository.sources_removed" "$file")"
    # else
    #     log::info "$(tr::t "cudarepo::uninstall_cuda_repository.no_sources")"
    # fi

    # Atualiza a lista de pacotes depois de remover o repositório CUDA
    packages::update

    return 0
}

tr::add "pt_BR" "cudarepo::uninstall_cuda_repository.remove_failure" "Falha ao remover o pacote cuda-keyring: código %1."
tr::add "pt_BR" "cudarepo::uninstall_cuda_repository.not_installed" "Pacote cuda-keyring não está instalado. Pulando."
tr::add "pt_BR" "cudarepo::uninstall_cuda_repository.removed" "Pacote cuda-keyring removido com sucesso."
tr::add "pt_BR" "cudarepo::uninstall_cuda_repository.removing_sources" "Removendo arquivo de fontes do CUDA..."
tr::add "pt_BR" "cudarepo::uninstall_cuda_repository.sources_removed" "Arquivo de fontes removido: %1"
tr::add "pt_BR" "cudarepo::uninstall_cuda_repository.no_sources" "Nenhum arquivo de fontes do CUDA encontrado para remover."

tr::add "en_US" "cudarepo::uninstall_cuda_repository.remove_failure" "Failed to remove cuda-keyring package: code %1."
tr::add "en_US" "cudarepo::uninstall_cuda_repository.not_installed" "cuda-keyring package is not installed. Skipping."
tr::add "en_US" "cudarepo::uninstall_cuda_repository.removed" "cuda-keyring package removed successfully."
tr::add "en_US" "cudarepo::uninstall_cuda_repository.removing_sources" "Removing CUDA source list..."
tr::add "en_US" "cudarepo::uninstall_cuda_repository.sources_removed" "Removed CUDA source list: %1"
tr::add "en_US" "cudarepo::uninstall_cuda_repository.no_sources" "No CUDA source list found to remove."

cudarepo::lock_cuda_version() {
    local version="$1"
    local file="${2:-"/etc/apt/preferences.d/nvidia"}"
    mkdir -p "$(dirname "$file")"

    printf "Package: src:*nvidia*:any src:cuda-drivers:any src:cuda-compat:any\nPin: version %s\nPin-Priority: 1000\n" "$version" > "$file"

    log::info "$(tr::t_args "cudarepo::lock_cuda_version.locked" "$version" "$file")"
}

cudarepo::unlock_cuda_version() {
    local file="${1:-"/etc/apt/preferences.d/nvidia"}"

    if [[ -f "$file" ]]; then
        rm -f "$file"
        log::info "$(tr::t_args "cudarepo::unlock_cuda_version.unlocked" "$file")"
    else
        log::info "$(tr::t_args "cudarepo::unlock_cuda_version.not_found" "$file")"
    fi
}

tr::add "pt_BR" "cudarepo::lock_cuda_version.locked" "Versão do CUDA %1 travada com sucesso no arquivo %2."
tr::add "pt_BR" "cudarepo::unlock_cuda_version.unlocked" "Arquivo de preferência %1 removido, desbloqueando a versão do CUDA."
tr::add "pt_BR" "cudarepo::unlock_cuda_version.not_found" "Arquivo de preferência %1 não encontrado. Nenhuma versão do CUDA foi desbloqueada."

tr::add "en_US" "cudarepo::lock_cuda_version.locked" "CUDA version %1 locked successfully in file %2."
tr::add "en_US" "cudarepo::unlock_cuda_version.unlocked" "Preference file %1 removed, CUDA version unlocked."
tr::add "en_US" "cudarepo::unlock_cuda_version.not_found" "Preference file %1 not found. No CUDA version was unlocked."

cudarepo::install_cuda_proprietary() {
    log::info "$(tr::t "cudarepo::install_cuda_proprietary.start")"

    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "cuda-drivers"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    log::info "$(tr::t "cudarepo::install_cuda_proprietary.success")"
    tui::msgbox::custom "" "$(tr::t "cudarepo::install_cuda_proprietary.success")"
    tui::msgbox::need_restart

    script::exit
}

tr::add "pt_BR" "cudarepo::install_cuda_proprietary.start" "Iniciando instalação do driver NVIDIA..."
tr::add "pt_BR" "cudarepo::install_cuda_proprietary.success" "Driver NVIDIA instalado com sucesso."

tr::add "en_US" "cudarepo::install_cuda_proprietary.start" "Starting NVIDIA driver installation..."
tr::add "en_US" "cudarepo::install_cuda_proprietary.success" "NVIDIA driver installed successfully."

cudarepo::install_cuda_opensource() {
    log::info "$(tr::t "cudarepo::install_cuda_opensource.start")"

    # Instala o driver da NVIDIA
    local status
    ( # Subshell para isolar a variável DEBIAN_FRONTEND
        export DEBIAN_FRONTEND=noninteractive
        packages::install "nvidia-open"
    )
    status=$?

    if [[ $status -ne 0 ]]; then
        log::critical "$(tr::t "default.script.canceled.byfailure")"
        log::input _ "$(tr::t "default.script.pause")"
        return 1
    fi

    log::info "$(tr::t "cudarepo::install_cuda_opensource.success")"
    tui::msgbox::custom "" "$(tr::t "cudarepo::install_cuda_opensource.success")"
    tui::msgbox::need_restart

    script::exit
}

tr::add "pt_BR" "cudarepo::install_cuda_opensource.start" "Iniciando instalação do driver NVIDIA..."
tr::add "pt_BR" "cudarepo::install_cuda_opensource.success" "Driver NVIDIA instalado com sucesso."

tr::add "en_US" "cudarepo::install_cuda_opensource.start" "Starting NVIDIA driver installation..."
tr::add "en_US" "cudarepo::install_cuda_opensource.success" "NVIDIA driver installed successfully."
