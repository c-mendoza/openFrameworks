openFrameworks + CMake
================

This is an experimental openFrameworks branch that adds a CMake build system.

The goals of this build system are:

* Be a true cross-platform build system, serving every platform that OF targets.
* Obviate the need for the Project Generator: addons are added in your project's CMakeLists file.
* Enabling the use of CMake-compatible IDE's like CLion and VS Code.
* Make openFrameworks an easily installable package, enabling its integration into other
  projects (imagine OF in a JUCE app, for example).

## Structure

The fork adds the following files:

- A `CMakeLists.txt` file at the openFrameworks root. This file configures and builds the OF library and creates the installation rules.
- A `cmake` folder that contains some helper files. `of_macros.cmake` is the most interesting one at the moment.
- A `tests/cmake` folder, which has tests/examples of the build system.

## Quickstart

The easiest way to test is by using CLion.

## Status

Currently, the build system can do the following:

* Build openFrameworks as a static library.
* Build an OF app using a simple CMakeList.txt template.
* Provides limited addon support in the app's CMakeLists file. The system is able to load addons that follow the "standard" addon file structure and which don't require anything other than compilation of sources and linking of provided libraries.

### Targets/Platforms Supported

* Windows VS
* MacOS

## Getting Started

1. Clone this branch.
2. Go to `{of_root}/tests/cmake/cmakeTest` and open `CMakeLists.txt` in your CMake-capable IDE.
3. Config, build and run.

If you are using CLion, the process would be:

1. Open the CMakeLists.txt file *as a project*.
2. The CMake Profiles window should show up. Add a Release profile if you want.
3. The project will load. In the targets dropdown, make sure that `cmakeTest` is selected and
   build/run.

## Organization

## Disclaimers

I am not a CMake expert, so any suggestions for improvements are welcomed!