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

- A
  `CMakeLists.txt` file at the openFrameworks root. This file configures and builds the OF library and creates the installation rules.
- A `cmake` folder that contains some helper files.
  `of_macros.cmake` is the most interesting one at the moment.
- A `tests/cmake` folder, which has tests/examples of the build system.

## Quickstart

1. Clone this branch.
2. Download the OF libraries using the appropriate script.

### Using terminal

1. Open a terminal in the openFrameworks root directory and type the following:

```
cmake -DCMAKE_BUILD_TYPE=Debug -B cmake-build-debug
cmake --build cmake-build-debug --target build_and_install -j 8

cmake -DCMAKE_BUILD_TYPE=Release -B cmake-build-release
cmake --build cmake-build-release --target build_and_install -j 8
```

2. In the terminal, change directory to `tests/cmake/cmakeTest`
3. Type:

```
cmake -DCMAKE_BUILD_TYPE=Release -B cmake-build-release
cmake --build cmake-build-release --target cmakeTest -j 8
```

That should build the test app in the `bin` directory.

### Using CLion

I highly recommend using [CLion](https://www.jetbrains.com/clion/) as an IDE!

1. In the openFrameworks root directory, open `CMakeLists.txt` and **open it as a Project**.
2. Add at least a Debug and a Release profile in the window that appears.
3. From the targets drop-down menu, select `build_and_install`.
4. Press the build button.
5. If you want a Release build, change the config and build once more.

Now we will build the test ofApp:

1. From `tests/cmake/cmakeTest`, open `CMakeLists.txt` and **open it as a Project**.
7. Again, add a Debug and Release configuration.
8. Select the Release config, select `cmakeTest` as a target and press the Run button.

## Status

### Build
|   Platform    | Status | Notes                                                           |
|:-------------:|:------:|-----------------------------------------------------------------|
|     MacOS     |   ✅    | Only tested on Sequoia (15.6)                                   |
|    Windows    |   ⚠️   | Only `Release` or `RelWithDebInfo` builds. `Debug` builds crash | 
| Anything else |   ❌    | Not started yet.                                                |

### Addons

* There is limited addon support in the app's CMakeLists file via the function `ofIncludeAddon`.
* The system is able to load addons
  that follow the "standard" addon file structure and which don't require anything other than compilation of sources and linking of provided libraries.
* Addons can be *global* (from the `openFrameworks/addons` folder) or
  *local* (the addon's folder is located in the root of your ofApp project). 
* When an addon exists both locally and globally, the local addon is given preference by 
  `ofIncludeAddon`.

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