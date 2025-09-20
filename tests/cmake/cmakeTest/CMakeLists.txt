cmake_minimum_required(VERSION 3.28)

# Set the location of the openFrameworks directory:
set(OF_DIRECTORY ../../..)
cmake_path(ABSOLUTE_PATH OF_DIRECTORY
        BASE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        OUTPUT_VARIABLE OF_DIRECTORY
)
message("OF DIRE: ${OF_DIRECTORY}")
project(cmakeTest)

# Include the main CMakeLists, this adds OF as a target and includes the helper macros
# TODO: Turn this into find_package
include(${OF_DIRECTORY}/cmake/of_macros.cmake)
# This seems to be the only thing that sets the c++ standard...
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)
ofDetectTarget()
ofSetInstallPrefix()
message("${CMAKE_INSTALL_PREFIX}")

find_package(openFrameworks REQUIRED)

# Declare your project

# Add the source files that you want to compile with your project
file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

# This creates your app! Give it a name and pass it the list of sources
ofApp("cmakeTest" "${SOURCES}")

#target_link_libraries(${PROJECT_NAME} PRIVATE openFrameworks::of_static)

# Debugging macro, this just lists the sources that will be compiled
#ofPrintList(SOURCES)

# This function will include an addon. Please note that some addons may not work at the moment. ofxPoco will work though.
ofIncludeAddon(ofxPoco)

#that's it!
