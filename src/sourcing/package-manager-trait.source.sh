#!/bin/bash
# @author Exadra37(Paulo Silva) <exadra37ingmailpointcom>
# @since  2016/06/04
# @link   https://exadra37.com

set -e


#################################################################################################################################################################
# Functions for Sourcing and Cloning Dependencies
#################################################################################################################################################################

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

                        Git_Clone_Required_Package_Recursively "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "${for_vendor_path}"

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

        git clone -q -b "${package_version}" --depth 1 "${from_github_repo}" "${to_vendor_path}" &> /dev/null

        # We only want to checkout to a new branch if package version is a tag, because when is a branch git clone will do that for us.
        if Is_Git_Tag "${package_version}" "${to_vendor_path}"
            then
                cd "${to_vendor_path}"

                git checkout -q -b "${package_version}"
        fi
    }

    function Is_Git_Tag()
    {
        ### VARIABLES ARGUMENTS ###

            local _package_version="${1?}"
            local _to_vendor_path="${2}"


        ### EXECUTION ###

            if [ -z "$(cd "${_to_vendor_path}" && git tag)" ]
                then
                    return 1 # no git tags
            fi

            return 0 # we have git tags
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
