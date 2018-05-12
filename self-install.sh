#!/bin/bash
# @package exadra37-docker/php-development
# @link    https://gitlab.com/u/exadra37-docker/php-development
# @since   11 February 2017
# @license GPL-3.0
# @author  Exadra37(Paulo Silva) <exadra37ingmailpointcom>
#
# Social Links:
# @link    Auhthor:  https://exadra37.com
# @link    Gitlab:   https://gitlab.com/Exadra37
# @link    Github:   https://github.com/Exadra37
# @link    Linkedin: https://uk.linkedin.com/in/exadra37
# @link    Twitter:  https://twitter.com/Exadra37

set -e


########################################################################################################################
# Functions
########################################################################################################################

    function Print_Fatal_Error()
    {
        printf "\n \e[1;101m ${1}: \e[30;48;5;229m ${2} \e[0m \n"
        echo
        exit 1
    }

    function Print_Info()
    {
        printf "\n\e[1;36m ${1}:\e[0m ${2} \n"
    }

    function Print_Warning()
    {
        printf "\n\e[1;33m ${1}:\e[0m ${2} \n"
    }

    function Print_Success()
    {
        printf "\n\e[1;42m ${1}:\e[30;48;5;229m ${2} \e[0m \n"
    }


    function Abort_If_Url_Not_Available()
    {
        ### VARIABLES ARGUMENTS ###

            local _url="${1}"


        ### VARIABLES COMPOSITION ###

            local _http_status_code=$( curl -L -s -o /dev/null -w "%{http_code}" "${_url}")


        ### EXECCUTION ###

            if [ "${_http_status_code}" -gt 299 ]
                then
                    Print_Warning "Http Status Code" "${_http_status_code}"
                    Print_Fatal_Error "Url not Available" "${_url}"
            fi
    }

    function Abort_If_Sym_Link_Already_Exists()
    {
        ### VARIABLES ARGUMENTS ###

            local _sym_link_name="${1?}"


        ### EXECUTION ###

            if [ -L "${_sym_link_name}" ]
                then
                    Print_Fatal_Error "Sym Link already exists" "${_sym_link_name}"
            fi
    }

    function Abort_If_Already_Installed()
    {
        ### VARIABLES ARGUMENTS ###

            local _package_manager_script="${1:?}"


        ### EXECUTION ###

            if [ -f "${_package_manager_script}" ]
                then
                    Print_Fatal_Error "Bash Package Manager is already installed" "${_package_manager_script}"
            fi
    }

    function Install_Bash_Package_Manager()
    {
        ### VARIABLES ARGUMENTS ###

            local _bash_package_manager_version="${1?}"

            local _git_url="${2?}"

            local _package_manager_dir="${3?}"


        ### EXECUTION ###

            Print_Info "Installing Bash Package Manager from" "${_git_url}"

            mkdir -p "${_package_manager_dir}"

            cd "${_package_manager_dir}"

            git clone -q --depth 1 -b "${_bash_package_manager_version}" "${_git_url}" .

            # we want to ignore this type of errors:
            #   fatal: A branch named 'last-stable-release' already exists.
            git checkout -q -b "${_bash_package_manager_version}" 2>/dev/null || true
    }

    function Create_Sym_Link()
    {
        ### VARIABLES ARGUMENTS ###

            local _from_script="${1?}"

            local _sym_link="${2?}"


        ### EXECUTION ###

            Print_Info "${_sym_link} is a Sym Link pointing to" "${_from_script}"

            ln -s "${_from_script}" "${_sym_link}"
    }

    function Is_Home_User_Bin_Not_In_Path()
    {
        ### VARIABLES ARGUMENTS ###

            local _home_path="${1}"
            local _file_name="${2}"
            local _bin_dir="${3?}"


        ### VARIABLES COMPOSITION ###

            local _shell_file="${_home_path}"/"${_file_name}"


        ### EXECCUTION ###

            if [ -z "${PATH##*${_bin_dir}*}" ]
                then
                    return 0 # true
            fi

            return 1 # false
    }


    function Export_Path ()
    {
        ### VARIABLES DEFAULTS ###

            local _home_path=/home/"${USER}"
            local _bin_dir="${1?}"

            
        ### EXECCUTION ###

            if [ -z "${PATH##*${_bin_dir}*}" ]
                then
                    PATH=${_bin_dir}:${PATH}
                    export PATH
            fi
    }

    function Tweet_Me()
    {
        ### VARIABLES DEFAULTS ###

            local _message="All #Developers, #DevOps and #SysAdmins should try #Bash_Package_Manager by @exadra37."
            local _message="${_message// /\%%20}"
            local _message="${_message//#/\%%23}"
            local _twitter_url="https://twitter.com/home?status=${_message}"


        ### EXECCUTION ###

            Print_Info "Share Me On Twitter" "${_twitter_url}"
            echo
    }


########################################################################################################################
# Variables Defaults
########################################################################################################################

    sym_link_name="bpm"

    script_name="package-manager"

    git_url=https://github.com/exadra37-bash/package-manager.git


########################################################################################################################
# Variables Arguments
########################################################################################################################

    bash_package_manager_version="${1:-last-stable-release}"

    bin_dir="${2:-/home/${USER}/bin}"

    package_manager_dir="${bin_dir}/vendor/exadra37-bash/package-manager"

    package_manager_script="${package_manager_dir}/src/${script_name}.sh"

    sym_link="${bin_dir}/${sym_link_name}"

    bin_package_installer="https://gitlab.com/exadra37-bash/bin-package-installer/raw/last-stable-release/self-installer.sh"

########################################################################################################################
# Execution
########################################################################################################################

    #Abort_If_Url_Not_Available "${git_url}"
    Abort_If_Url_Not_Available "${bin_package_installer}"

    #Abort_If_Sym_Link_Already_Exists "${sym_link}"

    # Abort_If_Sym_Link_Already_Exists "${bin_dir}/${script_name}"

    # Abort_If_Already_Installed "${package_manager_script}"

    # Install_Bash_Package_Manager "${bash_package_manager_version}" "${git_url}" "${package_manager_dir}"

    # Create_Sym_Link "${package_manager_script}" "${sym_link}"

    # Export_Path "${bin_dir}"

    curl -L ${bin_package_installer} | bash -s -- \
        -n exadra37-bash \
        -p package-manager \
        -t ${bash_package_manager_version} \
        -s bpm:src/package-manager.sh \
        -b "${bin_dir}"

    # Let's test it
    bpm --help

    Tweet_Me
