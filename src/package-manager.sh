#!/bin/bash
# @author Exadra37(Paulo Silva) <exadra37ingmailpointcom>
# @since  2016/06/04
# @link   https://exadra37.com

set -e


#################################################################################################################################################################
# Sourcing Dependencies
#################################################################################################################################################################

    script_dir=$( cd "$( dirname "$0" )" && pwd )

    source "${script_dir}/sourcing/package-manager-trait.source.sh"


#################################################################################################################################################################
# Execution
#################################################################################################################################################################

    # examples how to install a package dependency from:
    #  - default gitgub repo service -> ./package-manager.sh install exadra37-bash file-system 0.1.0
    #  - other repo service -> ./package-manager.sh install exadra37-bash file-system 0.1.0 gitlab.com
    "$@"
