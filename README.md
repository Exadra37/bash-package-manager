# BASH PACKAGE MANAGER

To keep our code organized, reusable and decoupled as much as possible, we need to organize it in different bash scripts and packages, but at same time we need an easy way to manage all this dependencies.

Bash Package Manager `bpm` will allow to require packages we depend on, with a simple command.

It can also automaticcly resolve and source dependencies within our own bash scripts, from code repositories like Github or Gitlab.


## How to install

The recommended way is to clone this package into the `vendor` folder off the Bash project we need to handle the dependencies and make an alias to it.

##### Install locally in your project:

```bash
cd /path/to/bash/project/root-folder
mkdir -p vendor/exadra37-bash
git clone -b master --single-branch --depth 1 https://github.com/exadra37-bash/package-manager.git vendor/exadra37-bash/package-manager
```

From now on we will use an `alias` to call our `./vendor/exadra37-bash/package-manager/src/package-manager.sh`:

##### Temporary Alias

```bash
alias bpm=./vendor/exadra37-bash/package-manager/src/package-manager.sh
```

##### Permanent Alias

```bash
# for ZSH shell - IF YOU ARE NOT USING IT, YOU SHOULD ;)
echo "alias bpm=./vendor/exadra37-bash/package-manager/src/package-manager.sh" >> ~/.zshrc && . ~/.zshrc

# for Bash shell
echo "alias bpm=./vendor/exadra37-bash/package-manager/src/package-manager.sh" >> ~/.bashrc && . ~/.bashrc
```

##### Lets try out our new alias:

```bash
╭─Exadra37 in ~/Downloads/demo
╰─○ bpm --version

Bash Package Manager 0.1.0  by Exadra37
```

**NOTES:**

* the alias `bpm` will work for any of your projects using this package, therefore you may want to add it permanently to your shell.
* with alias or without alias, this package must be always called from the root of your project and have the package already installed in the vendor folder.

## How to Use

This package can be used from command line or from any bash script that needs to source some dependencies.

#### From Command Line

Assuming we have followed the previous steps in `How to Install` and that we have created the alias and we still in the root of our package or project, we can try some examples.

##### Auto Install Recursively

Invoking `install` will read all required packages from file `required-packages.pkg` if it exists in the root of your project or package.

This is done recursively, by looking in each package it installs, for the file `required-packages.pkg` and installing also that packages, until no more required packages are found to install.

The file `required-packages.pkg` must require a package per line in the format `repository-service-url,vendor-name,package-name,package-version`.

The `required-packages.pkg` file should look like:

```bash
github.com,exadra37-bash,file-system,0.2.0
github.com,exadra37-bash,git-helpers,0.1.0
github.com,exadra37-bash,pretty-print,0.1.0
github.com,exadra37-bash,strings-manipulation,0.2.0
github.com,exadra37-bash,package-signature,0.1.0
```

To auto install recursively the above packages, contained in the root of your project or package, just type:

```bash
bpm install
```

##### Manual Require Recursively

When invoking `require`, we need to specify in the arguments the `vendor-name` `package-name` `package-version` and optionally the `repository-service-url`

###### Require from default Repository Service

To install from the default repository provider, Github, the package `exadra37-bash/file-system` in version `0.2.0`, we just need to type in command line:

```bash
bpm require exadra37-bash file-system 0.2.0
```

###### Require from other Repositories Services

To install the same package, from **Example 1**, but from other repository service provider, like Gitlab, we will need to add into the end the domain name `gitlab.com`:

```bash
bpm require exadra37-bash file-system 0.2.0 gitlab.com
```

Now that we have the required packages to develop our project or package, we just need to source them as usually we do with any other file we want to include in our Bash Script.

```bash
# this example is assuming that the script from where we source,
#  is located 1 level inside our project or package, like in `src` folder
source ../vendor/vendor-name/package-name/src/sourcing/file-to-source.sh
```


#### From Within a Bash Script

Considering that the instructions in **How to Install** have been followed, the following example will show how to integrate Bash Package Manager functionality to Auto Source Dependencies into any Bash Script.

To use it from within any bash script, just include this lines:

```bash
# we need to determine the absolut path for this bash script
script_path=$( cd "$( dirname "$0" )" && pwd )

# we need to manually source our Bash Package Manager
source "${script_path}/../vendor/exadra37-bash/package-manager/src/sourcing/package-manager-trait.source.sh"

# Now we can automaticcly source any dependency we need to run our bash script
Auto_Source_Dependency "exadra37-bash" "pretty-print" "0.1.0" "src/sourcing/pretty-print-trait.source.sh" "${script_path}/../"
```

In order to see it working lets create a demo script:

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

 ALERT: Pretty Print can do a lot more funny stuff... go to https://github.com/exadra37-bash/pretty-print for more examples.
```

If the above output can't be seen, please perform all the steps again and ensure that you not skip any or make some typos.
