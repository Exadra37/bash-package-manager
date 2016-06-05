#!/bin/bash
# @author Exadra37(Paulo Silva) <exadra37ingmailpointcom>
# @since  2016/06/04
# @link   https://exadra37.com

set -e


#################################################################################################################################################################
# Functions for Sourcing and Cloning Dependencies
#################################################################################################################################################################

    function Git_Clone_Dependency
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local repo_domain_name="${4}"
        local base_path="${5:-.}"
        local output_to="${6}"

        local vendor_name_path="${base_path}/vendor/${vendor_name}"

        [ -z "${repo_domain_name}" ] && repo_domain_name="github.com"

        # https://github.com/exadra37-bash/file-system.git
        local from_github_repo="https://${repo_domain_name}/${vendor_name}/${package_name}.git"

        local to_vendor_path="${vendor_name_path}/${package_name}"

        if [ ! -d "${vendor_name_path}" ]
            then
                mkdir -p "${vendor_name_path}"
        fi

        if [ -z "${output_to}" ]
            then
                git clone -q -b "${package_version}" --single-branch --depth 1 "${from_github_repo}" "${to_vendor_path}"

            else
                git clone -q -b "${package_version}" --single-branch --depth 1 "${from_github_repo}" "${to_vendor_path}" &> "${output_to}"
        fi
    }

    function Auto_Source_Dependency
    {
        local vendor_name="${1}"
        local package_name="${2}"
        local package_version="${3}"
        local file_name="${4}"
        local base_path="${5:-.}"
        local repo_domain_name="${6}"

        local output_to="/dev/null"

        local source_path="${base_path}/vendor/${vendor_name}/${package_name}/${file_name}"

        [ -f "${source_path}" ] || Git_Clone_Dependency "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}" "${base_path}" "${output_to}"

        source "${source_path}"
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

        Git_Clone_Dependency "${vendor_name}" "${package_name}" "${package_version}" "${repo_domain_name}"
    }
