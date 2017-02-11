#!/bin/bash
# @package exadra37-docker/php-development
# @link    https://gitlab.com/u/exadra37-docker/php-development
# @since   2017/02/11
# @license MIT
# @author  Exadra37(Paulo Silva) <exadra37ingmailpointcom>
#
# Social Links:
# @link    Auhthor:  https://exadra37.com
# @link    Github:   https://github.com/Exadra37
# @link    Linkedin: https://uk.linkedin.com/in/exadra37
# @link    Twitter:  https://twitter.com/Exadra37

set -e


########################################################################################################################
# Functions
########################################################################################################################

    function Is_Home_User_Bin_Not_In_Path()
    {
        local home_path="${1}"
        local file_name="${2}"


        local shell_file="${home_path}"/"${file_name}"

        ( [ $(grep -c "${home_path}" "${shell_file}") -eq 0 ] || [ $(grep -c ~/bin "${shell_file}") -eq 0 ] ) && return 0 || return 1
    }

    function Export_Path ()
    {
        local home_path=/home/"${USER}"

        local home_bin_path="${home_user}/bin"

        if [ -f "${home_path}"/.profile ] && Is_Home_User_Bin_Not_In_Path "${home_path}" ".profile"
            then
                echo "export PATH=${home_bin_path}:${PATH}"  >> "${home_path}/.profile"
        fi

        if [ -f "${home_path}"/.bash_profile ] && Is_Home_User_Bin_Not_In_Path "${home_path}" ".bash_profile"
            then
                echo "export PATH=${home_bin_path}:${PATH}"  >> "${home_path}/.bash_profile"
        fi

        if [ -f "${home_path}"/.zshrc ] && Is_Home_User_Bin_Not_In_Path "${home_path}" ".zshrc"
            then
                echo "export PATH=${home_bin_path}:${PATH}"  >> "${home_path}/.zshrc"
        fi

        return 0
    }

########################################################################################################################
# Variables
########################################################################################################################

    package_manager_dir=/home/"${USER}"/bin/.vendor/exadra37-bash/package-manager


########################################################################################################################
# Execution
########################################################################################################################

    mkdir -p ${package_manager_dir} &&
        curl -L https://github.com/exadra37-bash/package-manager/archive/0.2.0.tar.gz | tar -zxvf - -C ${package_manager_dir} --strip-components=1

    ln -s "${package_manager_dir}"/src/package-manager.sh /home/"${USER}"/bin/bpm

    Export_Path

    # Let's test it
    bpm --help
