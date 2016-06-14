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
        local output_to="${6}"

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
                Git_Soft_Clone "${from_github_repo}" "${for_vendor_path}" "${package_version}" "${output_to}"
        fi

        Install_Required_Packages "${for_vendor_path}"
    }

    function Git_Soft_Clone
    {
        local from_github_repo="${1}"
        local to_vendor_path="${2}"
        local package_version="${3}"
        local output_to="${4}"

        if [ -z "${output_to}" ]
            then
                git clone -q -b "${package_version}" --single-branch --depth 1 "${from_github_repo}" "${to_vendor_path}"

            else
                git clone -q -b "${package_version}" --single-branch --depth 1 "${from_github_repo}" "${to_vendor_path}" #&> "${output_to}"
        fi
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
        local output_to="/dev/null"

        local source_path="${for_vendor_path}/${vendor_name}/${package_name}/${file_name}"

        if [ -f "${source_path}" ]
            then
                source "${source_path}"
            else
                Git_Clone_Required_Package_Recursively "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "${for_vendor_path}" "${output_to}"

                source "${source_path}"

                Append_To_Required_Packages "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}"
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

        Git_Clone_Required_Package_Recursively "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}"

        Append_To_Required_Packages "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}"
    }

    function Append_To_Required_Packages
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local repo_domain_name="${4:-github.com}"

        local required_packages_file="./required-packages.pkg"

        if [ -f "${required_packages_file}" ] && grep -iq "${vendor_name},${package_name}" "${required_packages_file}"
            then
                Print_Fatal_Error "Package already exists."
            else
                Append_To_File "${required_packages_file}" "${repo_domain_name},${vendor_name},${package_name},${package_version}"
        fi
    }

    function install
    {
        Install_Required_Packages
    }


#################################################################################################################################################################
# Auto Source Dependencies
#################################################################################################################################################################

Auto_Source_Dependency "exadra37-bash" "file-system" "0.3.0" "src/sourcing/file-system-trait.source.sh"
Auto_Source_Dependency "exadra37-bash" "pretty-print" "0.1.0" "src/sourcing/pretty-print-trait.source.sh"
