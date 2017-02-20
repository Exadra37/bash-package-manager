# HOW TO USE

This package can be used from command line or from any bash script that needs to source some dependencies.

#### From Command Line

Assuming that the previous steps in `How to Install` have been followed successfully, we can try some examples.

#### Auto Install Recursively

Invoking `install` will read all required packages from file `required-packages.pkg` if it exists in the root of your project or package.

This is done recursively, by looking in each package it installs, for the file `required-packages.pkg` and installing also that packages, until no more required packages are found to install.

The file `required-packages.pkg` must require a package per line in the format `repository-service-url,vendor-name,package-name,package-version`.

The file `required-packages.pkg` located in the root of you package or project should look like this:

```bash
github.com,exadra37-bash,file-system,0.2.0
github.com,exadra37-bash,git-helpers,0.1.0
github.com,exadra37-bash,pretty-print,0.1.0
github.com,exadra37-bash,strings-manipulation,0.2.0
github.com,exadra37-bash,package-signature,0.1.0
```
**NOTE: DO NOT LEAVE BLANK SPACES BETWEEN COMMAS**

To auto install recursively the above packages, just type from the root of your project:

```bash
$ bpm install
```

#### Manual Require Recursively

When invoking `require`, we need to specify the following arguments:

* `vendor-name`
* `package-name`
* `package-version`
* `repository-service-url` (optional)

##### Require from default Repository Service Provider

To install from the default repository provider, Github, the package `exadra37-bash/file-system` in version `0.2.0`, we just need to type in command line:

```bash
$ bpm require exadra37-bash file-system 0.2.0
```

##### Require from other Repository Service Provider

To install the same package, from **Example 1**, but from other repository service provider, like Gitlab, we will need to add into the end the domain name `gitlab.com`:

```bash
$ bpm require exadra37-bash file-system 0.2.0 gitlab.com
```

Now that we have the required packages to develop our project or package, we just need to source them as usually we do with any other file we want to include in our Bash Script.

```bash
# this example is assuming that the script from where we source,
#  is located 1 level inside our project or package, like in `src` folder
source ../vendor/vendor-name/package-name/src/sourcing/file-to-source.sh
```


#### From Within a Bash Script

Considering that the instructions in **How to Install** have been followed, the following example will show how to integrate Bash Package Manager functionality to Auto Source Dependencies into any Bash Script.

##### To use it from within any bash script, just include this lines:

```bash
# we need to determine the absolut path for this bash script
script_path=$( cd "$( dirname "$0" )" && pwd )

# we need to manually source our Bash Package Manager
source "${script_path}/../vendor/exadra37-bash/package-manager/src/sourcing/package-manager-trait.source.sh"

# Now we can automaticcly source any dependency we need to run our bash script
Auto_Source_Dependency "exadra37-bash" "pretty-print" "0.1.0" "src/sourcing/pretty-print-trait.source.sh" "${script_path}/../"
```

##### In order to see it working lets create a demo script:

```bash
$ mkdir -p src && touch src/demo-auto-sourcing.sh && chmod +x src/demo-auto-sourcing.sh && vim src/demo-auto-sourcing.sh
```

##### Copy paste the below code into the `demo-auto-sourcing.sh`;

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

##### Let's run our demo script:

```bash
$ ./src/demo-auto-sourcing.sh

 SUCCESS: Auto Sourced Dependency Successfully :).

 INFO: The first time the script runs all dependencies are cloned from remote repositories, if they do not exist in the vendor folder.

 INFO: Next time we run this script, Auto Sourcing the Dependency will not need to clone it, therefore will run faster.

 ALERT: Pretty Print can do a lot more funny stuff... go to https://github.com/exadra37-bash/pretty-print for more examples.
```

If the above output can't be seen, please perform all the steps again and ensure that you do not skip any of them or that you are not making some typos.
