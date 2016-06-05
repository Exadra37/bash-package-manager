# BASH PACKAGE MANAGER

This package will allow to automaticcly resolve and source dependencies within our own bash scripts, from code repositories in Github or Gitlab.

## How to install

The recommended way is to clone this package into the `vendor` folder off the Bash project we need to handle the dependencies and make an alias to it.

Install locally in your project:

```bash
cd /path/to/bash/project/root/folder
mkdir -p vendor/exadra37-bash
git clone -b master --single-branch --depth 1 https://github.com/exadra37-bash/package-manager.git vendor/exadra37-bash/package-manager
```

From now on we will use an `alias` to call our `./vendor/exadra37-bash/package-manager/src/package-manager.sh`:

```bash
alias pkg-mng=./vendor/exadra37-bash/package-manager/src/package-manager.sh
```

Lets try out our new alias:

```bash
pkg-mng --version
```

**NOTES:**

* the alias `pkg-mng` will work for any of your projects using this package, therefore you may want to add it permanently to your shell.
* with alias or without alias, this package must be always called from the root of your project and have the package already installed in the vendor folder.

## How to Use

This package can be used from command line or from any bash script that needs to source some dependencies.

#### From Command Line

Assuming we have followed the previous steps in `How to Install` and that we have created the alias and have not changed from folder, we can try some examples.

##### Example 1

To install from the default repository provider, Github, the package `exadra37-bash/file-system` in version `0.2.0`, we just need to type in command line:

```bash
pkg-mng require exadra37-bash file-system 0.2.0
```

##### Example 2

To install the same package, from **Example1**, but from other repository service provider, like Gitlab, we will need to add into the end the domain name `gitlab.com`:

```bash
pkg-mng require exadra37-bash file-system 0.2.0 gitlab.com
```

##### Demo 1 - Use case as per Example 1 and Example 2

Now that we have installed our dependency, we are ready to source it from within our bash script.

Let's create a demo script:

```bash
mkdir -p src && touch src/demo-manual-sourcing.sh && chmod +x src/demo-manual-sourcing.sh && vim src/demo-manual-sourcing.sh
```

Copy paste the below code into the `demo-manual-sourcing.sh`;

```bash
#!/bin/bash
# @author Exadra37(Paulo Silva) <exadra37ingmailpointcom>
# @since  2016/06/05
# @link   https://exadra37.com

set -e


#################################################################################################################################################################
# Declare Variables
#################################################################################################################################################################

    script_path=$( cd "$( dirname "$0" )" && pwd )


#################################################################################################################################################################
# Sourcing Dependencies
#################################################################################################################################################################

    source "${script_path}/../vendor/exadra37-bash/file-system/src/sourcing/file-system-trait.source.sh"


#################################################################################################################################################################
# Execution
#################################################################################################################################################################

    # Lets see if we can use some of the nice File System functions

    script_dir="$( getScriptDir )"

    printf "\n SCRIPT DIR: ${script_dir} \n"

    printf "\n End of Demo \n"
```

Let's try our demo script:

```bash
╭─Exadra37 in ~/Downloads/demo
╰─○ ./src/demo-manual-sourcing.sh

 SCRIPT DIR: /home/exadra7/Downloads/demo/src

 End of Demo
```

If you can't see the above output, please try again and ensure that all the steps have been performed exactly as shown here.

#### From Within a Bash Script

To keep our code organized, reusable and decoupled as much as possible, we need to organize it in different bash scripts and packages, but at same time we need an easy way to manage all this dependencies.

Considering that the instructions in **How to Install** have been followed, the following example will show how to integrate Bash Package Manager functionality to Auto Source Dependencies into any Bash Script.

##### Example 3

To use it from within any bash script, just include this lines:

```bash
# we need to determine the absolut path for this bash script
script_path=$( cd "$( dirname "$0" )" && pwd )

# we need to manually source our Bash Package Manager
source "${script_path}/../vendor/exadra37-bash/package-manager/src/sourcing/package-manager-trait.source.sh"

# Now we can automaticcly source any dependency we need to run our bash script
Auto_Source_Dependency "exadra37-bash" "pretty-print" "0.1.0" "src/sourcing/pretty-print-trait.source.sh" "${script_path}/../"
```

In order to see it working lets try another Demo.

##### Demo 2 - Use case as per Example 3

Let's create another demo script:

```bash
mkdir -p src && touch src/demo-auto-sourcing.sh && chmod +x src/demo-auto-sourcing.sh && vim src/demo-auto-sourcing.sh
```

Copy paste the below code into the `demo-auto-sourcing.sh`;

```bash
#!/bin/bash
# @author Exadra37(Paulo Silva) <exadra37ingmailpointcom>
# @since  2016/06/04
# @link   https://exadra37.com

set -e


#################################################################################################################################################################
# Declare Variables
#################################################################################################################################################################

    script_path=$( cd "$( dirname "$0" )" && pwd )


#################################################################################################################################################################
# Sourcing Dependencies
#################################################################################################################################################################

    source "${script_path}/../vendor/exadra37-bash/package-manager/src/sourcing/package-manager-trait.source.sh"

    Auto_Source_Dependency "exadra37-bash" "pretty-print" "0.1.0" "src/sourcing/pretty-print-trait.source.sh" "${script_path}/../"


#################################################################################################################################################################
# Execution
#################################################################################################################################################################

    # Lets see if we can use some of the nice Pretty Print functions

    Print_Success "Auto Sourced Dependency Successfully :)."

    Print_Info "The first time the script runs all dependencies are cloned from remote repositories, if they do not exist in the vendor folder."

    Print_Info "Next time we run this script, Auto Sourcing the Dependency will not need to clone it, therefore will run faster."

    Print_Alert "Pretty Print can do a lot more funny stuff... go to https://github.com/exadra37-bash/package-manager for more examples."
```

Let's run our demo script:

```bash
╭─Exadra37 in ~/Downloads/demo
╰─○ ./src/demo-auto-sourcing.sh

 SUCCESS: Auto Sourced Dependency Successfully :).

 INFO: The first time the script runs all dependencies are cloned from remote repositories, if they do not exist in the vendor folder.

 INFO: Next time we run this script, Auto Sourcing the Dependency will not need to clone it, therefore will run faster.

 ALERT: Pretty Print can do a lot more funny stuff... go to https://github.com/exadra37-bash/package-manager for more examples.
```

If the above output can't be seen, please perform all the steps again and ensure that you not skip any or make some typos.
