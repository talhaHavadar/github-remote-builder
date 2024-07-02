# GitHub Remote Runner

GitHub remote runner is a simple wrapper script around Github CLI tool.
It utilises the Github actions to build the repos remotely, packs the build
artifacts and downloads the tarball that contains build artifacts.

# Why?

With the help of github-remote-runner you can cross build your application
without needing to install crossbuild tools which in some situations it is frustrating.

You may want to not turn your host machine into garbage, or even in some cases
you may not have a powerful machine to build the application fast so you can
utilize github runners to do the job and not put load into your development machine.

# How to use it?

## Prerequisites

- Github CLI
- Personal access token from Github (if you need to build private repos)

## Installation

- Fork this repo
- Add personal access token of yours into the repo you forked with name as `PAT_TOKEN`
- Clone the forked repo into your development machine
- Add the repo directory into path so you can use `gh-remote-builder` command
  anywhere
- `cd` into the repo that is available in github and you want to initiate remote
  build
- Run `gh-remote-builder init` this will initialise the configuration and will
  ask you to provide the github-remote-builder repo name, please enter your forked repo
- `init` command creates the files required for build in `.gh-remote-builder` directory
- Update contents of `prebuild`, `build` and `target-files` files as needed
- Lastly execute the `gh-remote-builder` which will start build using default values.
  Please see `gh-remote-builder --help` for details

# Usage

```
gh-remote-builder [options] [commands]

Example usage:
gh-remote-builder --arch=amd64 --target-files="target/debian;target/release" --out=download
starts a remote build for amd64 architecture, using current repo and
branch information, it will use the scripts defined in '.gh-remote-builder' directory
- prebuild
- build
- target-files (overridden by --target-files)
after build is finished it packs the files listed
in --target-files and downloads the artifacts into 'download' folder as
specified in --out

gh-remote-builder --target-repo="Badger-Embedded/badgerd-sdwirec" --target-ref=main
starts a remote build for amd64(by default) architecture, using
'Badger-Embedded/badgerd-sdwirec' repo and 'main' branch, it will use
use scripts defined in '.gh-remote-builder' directory
- prebuild
- build
- target-files
after build finished it packs the files listed in .gh-remote-builder/target-files
and downloads the artifacts into 'target'(by default) folder

options:
--help                          Prints out this message

--arch=<value>                  default: amd64

--target-repo=<value>           default: uses current github repo in the directory that the tool has been run

--target-ref=<value>            default: uses the active branch of the repo that the tool has been run

--prebuild-command=<value>      default: uses .gh-remote-builder/prebuild file as source
Commands that will run before build starts,
it is a nice place to install dependencies

--build-command=<value>         default: uses .gh-remote-builder/build file as source
Actual build command that will be executed
in build phase. A good example could be "cargo deb"

--target-files=<value>          default: uses .gh-remote-builder/target-files as source
File/Directory paths to be tarballed. Multiple
path can be provided by using ';' as delimiter
--out=<value>

commands:
init                            Initialises the gh-remote-builder
it creates initial config file if it is not created yet
creates the directory structure for .gh-remote-builder directory
adds .gh-remote-builder into .gitignore if there is a .gitignore in cwd
```
