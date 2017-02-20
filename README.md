# BASH PACKAGE MANAGER

To keep our code organized, reusable and decoupled as much as possible, we need to organize it in different bash scripts and packages, but at same time we need an easy way to manage all this dependencies.

Bash Package Manager `bpm` will allow to require packages we depend on, with a simple command.

It can also resolve and source dependencies within our own bash scripts, from code repositories like Github or Gitlab.


## AUTHOR

More information about the Author can be found [here](AUTHOR.md).


## CONTRIBUTORS

All contributors can be found [here](CONTRIBUTORS.md).


## LICENSE

This repository uses GPL-3.0 license, that you can find [here](LICENSE).


## CONTRIBUTING IN ISSUES / MERGE REQUESTS

All contributions are welcome provided that they follow [Contributing Guidelines](CONTRIBUTING.md), where you can find
how to _Create an Issue_ and _Merge Request_.


## ROAD MAP

Check [Milestones](https://gitlab.com/exadra37-bash/package-manager/milestones) to see what Goals I want to achieve.

Watch [Boards](https://gitlab.com/exadra37-bash/package-manager/boards) to keep track of what is going on.



## HOW TO INSTALL

To install just follow detailed instructions from [here](docs/how-to/install.md).


## HOW TO UNINSTALL

To uninstall just follow detailed instructions from [here](docs/how-to/uninstall.md).


## HOW TO USE

See usage examples [here](docs/how-to/use.md).


## BRANCHES

Branches are created as demonstrated [here](docs/how-to/create_branches.md).

This are the type of branches we can see at any moment in the repository:

* `master` - issues and milestones branches will be merge here.
* `last-stable-release` - matches the last stable tag created. Useful for automation tools.
* `issue-4_fix-email-validation` (issue-number_title) - each issue will have is own branch for development.
* `milestone-12_add-cache` (milestone-number_title) - all Milestone issues will start, track and merged here.

Only `master` and `last-stable-release` branches will be permanent ones in the repository and all other ones will be
removed once they are merged.
