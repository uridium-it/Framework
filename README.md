
# Framework

## Description

_**Framework**_ is a simple multi-platform package manager focused primarily on C++ development.

### The main functionalities:

* Download and install software artifacts to a local directory
* Download, Build and Install source packages from internet to your local directory

## Package Lifecycle

You have two primary workflows: 

    Download source code -> compilation -> installation -> artifact creation -> upload the artifact on GitHub

or:

    download the artifact from GitHub -> artifact installation

# Examples

You need to run `artifacts_system_loader` and `build_system_loader` only once

    artifacts_system_loader
    build_system_loader

**Example 1:** Downloads the precompiled package restinio (and its dependencies) for your system, into a staging directory.

    download_artifact restinio

**Example 2:** Install the package restinio (and its dependencies) under the directory `project_root`, by default `project_root` resides is on your user's home directory.

    install_artifact restinio

**Example 3:** Download the source for the library zlib, compile and install it under the directory `project_root`:

    load_package zlib
    build_install

**Example 4:** if you have zlib installed from the command above, you can now create the relative artifact:

    load_package zlib
    make_artifact

## Supported OS

The scripts provided have been developed with portability in mind and are written in a platform-independent manner. As a result,
they are expected to work seamlessly across a variety of processor architectures, including but not limited to:

    AMD64
    ARM64
    x86

The target operating systems and compilers for this project includes:

    Windows, with Microsoft's msvc compiler
    OSX, with Apple's clang compiler
    Linux, with GNU's gcc compiler

Cross compilation is not yet supported.

## Default source packages

_**Framework**_ includes a default collection of basic C and C++ libraries, along with their corresponding dependencies. Every library is provided with a build script. 
These scripts are provided out of the box as an example and serve as a foundation for building REST-Services with local DB functionalities (Boost ASIO + Restinio + Sqlite).

A basic Rest Service is provided as a separate template project, on our GitHub.

It is pretty easy to add your own scripts, you need to add two files in the directory `packages`:

* a json file with the metadata of your source library
* a script file, with the instructions to build your library


## Installation on Windows

To install the software follow these steps:

1) Copy the 'Framework' directory wherever you like to keep it.

2) Start a PowerShell window with Administrator privileges, and copy-paste this line:

    Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope CurrentUser

3) Right-click on the file `install.ps1` file and select `Run with PowerShell`.

An icon named Framework will be created on your desktop — double-click this icon to launch the ZSH shell.

## Installation on OSX

Start the `Terminal` app, and execute the commands:


    git clone https://github.com/uridium-it/Framework.git
    cd Framework
    ./install.zsh

After having completed the installation process, you'll need to start ZSH shell:

    zsh --login

## Installation on Linux

To install the software follow these steps:

1) Make sure that the following commands are present in your system:


    sed grep tar awk find jq xz cmake zsh wget git make curl gcc g++

If they are not present, please install them.

2) Start a terminal, and execute the commands:


    git clone https://github.com/uridium-it/Framework.git
    cd Framework
    ./install.sh

After having completed the installation process, you'll need to start ZSH shell:

    zsh --login

## Available libraries out of the box

Only twelve packages are available at the moment, but the system is easily extensible:

    boost
    catch2
    expected-lite
    fmt
    llhttp
    nlohmann-json
    openssl
    perl
    restinio
    sqlite_orm
    sqlite
    zlib

## Adding more packages

Each library includes an installation script and a JSON configuration file, both located in the `packages` directory.

## The .json file

The JSON file specifies the GitHub repository URL (`source_url`), and a tag or branch name (`version`), the URL's string should end with `.git`.

Alternatively the URL can point to file, the URL's string should end with '.zip' or '.tgz' or '.tar.gz', in this case `version` is a string that should represent the actual version number of the package.

Some packages may also define a `dependencies` property: a space-separated list of source packages required to complete the build process.


## The .zsh file

The scripts run inside a ZSH shell, that is the interpreter of the script.

It should contain at least the function:

    package_build_install()

As the name suggests it will be used to build and install the source code.

For example to build a cmake project, this will be your script:

    package_build_install(){ 
        cmake_build_install
    }

Optionally, the script file may implement a `package_update_source()` function. This function is executed immediately after the repository is downloaded, typically to patch the source code or fetch GitHub submodules.

## The example scripts

All scripts are written using functions from `functional.zsh` file, a function library developed to write portable and more readable code.

In particular all path internally are rendered in Unix format, but on windows they need to be transformed in powershell format. To do so we use the function `convert_path`, that on Windows convert the path and on Linux and MacOS keep the string unchanges.

for example:

    on Linux:    echo '/c/Program Files/Windows Explorer/explorer.exe' | convert_path | double_quote -> "/c/Program Files/Windows Explorer/explorer.exe"
    on Windows:  echo '/c/Program Files/Windows Explorer/explorer.exe' | convert_path | double_quote -> "C:/Program Files/Windows Explorer/explorer.exe"

The suggestion is to always convert and double quote all the path, especially on Windows, as shown above.
Note that the function `convert_back` does the opposite of `convert_path`.

## Adding more scripts

Using the files already present in the `packages` directory as examples, it is pretty easy to add new packages, 
in particular those who use CMake as build system.

For example take the package `nlohmann-json` has no dependencies, the build script, `nlohmann-json.zsh`, is just one command:

    package_build_install(){ 
        cmake_build_install -DJSON_BuildTests=OFF \
        -DJSON_MultipleHeaders=OFF \
        -DCMAKE_INSTALL_DATADIR=lib
    }

and the corresponding json file, 'nlohmann-json.json':

    {
        "package": {
            "name": "nlohmann-json",
            "version": "v3.12.0",
            "source_url": "https://github.com/nlohmann/json.git",
            "build_type": "Release"
        }
    }

The following function will be created from this json file:

    package_name()
    package_version()
    package_source_url()
    package_build_type()

and they will be available during the execution of the function `package_build_install()`


## Make your package available to other developers:

When you have your `.zsh` script and `.json` file, for example:

    packages/mylib.zsh
    packages/mylib.json

you can do:

   build_system_loader
   artifacts_system_loader
   load_package mylib
   package_name
   package_version
   download_source_package
   build_install -f
   make_artifact -f

Now you can upload the artifacts: this is actually just a git add/commit/push, using GitHub's Workflow release.

and on another machine (we need only the json file, on this one):

    download_artifact zlib
    install_artifact zlib

Basically once you compile your library once you can distribute the precompiled package (artifact), 
to multiple machines/developers, using this workflow.
