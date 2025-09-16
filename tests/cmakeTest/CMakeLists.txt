cmake_minimum_required(VERSION 3.28)

set(OF_ROOT ../../)

# TODO: Turn this into find_package
include(${OF_ROOT}/CMakeLists.txt)

project(cmakeTest)
file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp")

#of_print_list(SOURCES)

of_app("cmakeTest" "${SOURCES}")
of_include_addon(ofxPoco)
add_link_options($<$<CONFIG:Debug>:/VERBOSE>)

#add_executable(${PROJECT_NAME} ${SOURCES})
#of_set_current_app(${PROJECT_NAME}) # for macros machinery

#of_addon(https://github.com/jvcleave/ofxImGui.git develop)

#target_link_libraries(${PROJECT_NAME} PRIVATE of_static)

