#!/bin/bash
# @author Exadra37(Paulo Silva) <exadra37ingmailpointcom>
# @since  2016/06/04
# @link   https://exadra37.com

set -e


#################################################################################################################################################################
# Functions for Sourcing and Cloning Dependencies
#################################################################################################################################################################

    function Create_Sym_Links()
    {
        local _symlinks_map="${1?}"
        local _symlink_from_dir="${2?}"
        local _symlink_to_dir="${3?}"

        # symlinks map is like 'symlink:bash-script.sh' or 'symlink:bash-script.sh,symlink2:bash-script2.sh'
        IFS='|' read -ra maps <<< "${_symlinks_map}"
        for map in "${maps[@]}"
            do
                # Get everything before first occurrence of ':' in the $map var.
                # Like return demo from 'demo:bash-script.sh'.
                local _symlink=${map%%:*}

                # Get everything after last occurrence of ':' in the $map var.
                # Like returning 'bash-script.sh' from 'demo:bash-script.sh'.
                local _script_to_link=${map#*:}

                # Path like: /home/$USER/bin/vendor/vendor-name/package-name/scr/bash-script.sh
                local _symlink_to="${_symlink_to_dir}"/"${_script_to_link}"

                local _symlink_path="${_symlink_from_dir}/${_symlink}"

                if [ -z "${_symlink}" ] || [ -z "${_script_to_link}" ]
                    then
                        Print_Fatal_Error "Invalid SymLink map: ${map}"

                        exit 1
                fi

                if [ ! -L "${_symlink_path}" ]
                    then
                        Print_Info "${_symlink} is a SymLink pointing to" "${_symlink_to}"
                        ln -s "${_symlink_to}" "${_symlink_path}"
                fi
        done
    }

    function Install_Required_Packages
    {
        local package_path="${1:-.}"

        local packages_file="${package_path}/required-packages.pkg"

        local for_vendor_path="${package_path}/vendor"

        if [ -f "${packages_file}" ]
            then

                while read line
                    do

                        IFS=',' read -r -a package <<< "${line}"

                        local repo_domain_name="${package[0]}"
                        local vendor_name="${package[1]}"
                        local package_name="${package[2]}"
                        local package_version="${package[3]}"
                        local symlinks_map="${package[4]}"

                        Git_Clone_Required_Package_Recursively "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "${for_vendor_path}"

                        if [ ! -z "${symlinks_map}" ]
                            then
                                Create_Sym_Links "${symlinks_map}" "${package_path}" "${for_vendor_path}/${vendor_name}/${package_name}"
                        fi

                done < "${packages_file}"
        fi
    }

    function Git_Clone_Required_Package_Recursively
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local repo_domain_name="${4:-github.com}"
        local base_path="${5:-.}"

        local vendor_name_path="${base_path}/${vendor_name}"

        # https://github.com/exadra37-bash/file-system.git
        local from_github_repo="https://${repo_domain_name}/${vendor_name}/${package_name}.git"

        local for_vendor_path="${vendor_name_path}/${package_name}"

        if [ -d "${for_vendor_path}" ]
            then
                # decide what to do:
                #   - remove package in order git can clone it?
                #   - skip install, once we already have the package?
                printf "\n Already installed package ${from_github_repo} \n"
            else
                mkdir -p "${vendor_name_path}"
                Git_Soft_Clone "${from_github_repo}" "${for_vendor_path}" "${package_version}"
        fi

        Install_Required_Packages "${for_vendor_path}"
    }

    function Git_Soft_Clone
    {
        local from_github_repo="${1}"
        local to_vendor_path="${2}"
        local package_version="${3}"

        mkdir -p "${to_vendor_path}"

        cd "${to_vendor_path}"

        git clone -q -b "${package_version}" --depth 1 "${from_github_repo}" . 2> /dev/null

        # when the package version is a tag we want to create a new branch, otherwise want to ignore this 
        # type of errors:
        #   fatal: A branch named 'last-stable-release' already exists.
        git checkout -q -b "${package_version}" 2>/dev/null || true

        cd - > /dev/null
    }

    function Auto_Source_Dependency
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local file_name="${4}"
        local package_path="${5:-.}"
        local repo_domain_name="${6}"

        local for_vendor_path="${package_path}/vendor"

        local source_path="${for_vendor_path}/${vendor_name}/${package_name}/${file_name}"

        if [ -f "${source_path}" ]
            then
                source "${source_path}"
            else
                Git_Clone_Required_Package_Recursively "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "${for_vendor_path}"

                source "${source_path}"

                Append_To_Required_Packages "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "${package_path}"
        fi
    }

    function Source_Dependency
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local file_name="${4}"
        local base_path="${5:-.}"
        local repo_domain_name="${6}"

        local source_path="${base_path}/vendor/${vendor_name}/${package_name}/${file_name}"

        source "${source_path}"
    }

    function require
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local repo_domain_name="${4}"

        Git_Clone_Required_Package_Recursively "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "./vendor"

        Append_To_Required_Packages "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}"
    }

    function Append_To_Required_Packages
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local repo_domain_name="${4:-github.com}"
        local package_path="${5:-.}"

        local required_packages_file="${package_path}"/required-packages.pkg

        if [ ! -f "${required_packages_file}" ]
            then
                touch "${required_packages_file}"
        fi

        if grep -iq "${vendor_name},${package_name}" "${required_packages_file}" && ! grep -iq "${vendor_name},${package_name},${package_version}" "${required_packages_file}"
            then
                Print_Fatal_Error "Package ${vendor_name}/${package_name} already exists in a version different from the required ${package_version} version."
        elif ! grep -iq "${vendor_name},${package_name}" "${required_packages_file}"
            then
                Append_To_File "${required_packages_file}" "${repo_domain_name},${vendor_name},${package_name},${package_version}"
        fi
    }

    function install
    {
        Install_Required_Packages
    }

    function Print_Help
    {
        Print_Line_Break

        Print_Bold_Label_With_Text "USAGE: " "bpm [install, -h, --help, -v, --version]" "green" "yellow"

        Print_Line_Break
    }

    function Print_Version
    {
        local versionColor="green"
        local authorColor="yellow"

        local version=$(git describe --exact-match 2> /dev/null || git rev-parse --abbrev-ref HEAD)

        Print_Line_Break

        Print_Text "Bash Package Manager"

        Print_Line_Break

        Print_Text "Version: "

        Print_Text_Colored "${version}" "${versionColor}"

        Print_Line_Break

        Print_Text "Author: "

        Print_Text_Colored "Exadra37" "${authorColor}"

        Print_Empty_Line
    }


#################################################################################################################################################################
# Auto Source Dependencies
#################################################################################################################################################################

    #script_dir=$( cd "$( dirname "$0" )" && pwd )
    script_dir=$( dirname $(dirname $(readlink -f $0)))

    Auto_Source_Dependency "exadra37-bash" "file-system" "0.3.0" src/sourcing/file-system-trait.source.sh "${script_dir}"
    Auto_Source_Dependency "exadra37-bash" "pretty-print" "0.1.0" src/sourcing/pretty-print-trait.source.sh "${script_dir}"
