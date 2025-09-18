cmake_minimum_required(VERSION 3.28)

set(OF_ROOT ../../../)

# TODO: Turn this into find_package
include(${OF_ROOT}/CMakeLists.txt)

project(cmakeTest)
file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

#of_print_list(SOURCES)

ofApp("cmakeTest" "${SOURCES}")
ofIncludeAddon(ofxPoco)
#add_link_options($<$<CONFIG:Debug>:/VERBOSE>)

include_directories(${OF_ROOT}/addons/ofxKinect/src/extra)
#add_executable(${PROJECT_NAME} ${SOURCES})
#of_set_current_app(${PROJECT_NAME}) # for macros machinery

#of_addon(https://github.com/jvcleave/ofxImGui.git develop)

#target_link_libraries(${PROJECT_NAME} PRIVATE of_static)

