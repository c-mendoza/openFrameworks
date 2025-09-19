cmake_minimum_required(VERSION 3.28)

# Set the location of the openFrameworks directory:
set(OF_ROOT ../../../)

# Include the main CMakeLists, this adds OF as a target and includes the helper macros
# TODO: Turn this into find_package
include(${OF_ROOT}/CMakeLists.txt)

# Declare your project
project(cmakeTest)

# Add the source files that you want to compile with your project
file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

# Debugging macro, this just lists the sources that will be compiled
#ofPrintList(SOURCES)

# This creates your app! Give it a name and pass it the list of sources
ofApp("cmakeTest" "${SOURCES}")

# This function will include an addon. Please note that some addons may not work at the moment. ofxPoco will work though.
ofIncludeAddon(ofxPoco)

#that's it!
