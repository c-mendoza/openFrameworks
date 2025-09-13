
function(of_include_addon NAME_ADDON)
    set(GLOBAL_ADDON_PATH "${OF_DIRECTORY}/addons/${NAME_ADDON}")
    set(LOCAL_ADDON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${NAME_ADDON}")

    # Look for a local addon first
    if (EXISTS ${LOCAL_ADDON_PATH})
        #        message(STATUS "Activating local addon from: ${LOCAL_ADDON_PATH}")
        if (EXISTS ${LOCAL_ADDON_PATH}/addon_config.cmake)
            message(STATUS "Activating local addon ${NAME_ADDON} with addon_config.cmake")
            include(${LOCAL_ADDON_PATH}/addon_config.cmake)
        else ()
            message(STATUS "Activating local addon ${NAME_ADDON} via generic function. The generic function makes assumptions about the addon's file structure and is not guaranteed to work in all cases.")
            of_load_generic_addon(${LOCAL_ADDON_PATH} ${NAME_ADDON})
        endif ()
        # Then look in the global addons
    elseif (EXISTS ${GLOBAL_ADDON_PATH})
        if (EXISTS ${GLOBAL_ADDON_PATH}/addon_config.cmake)
            message(STATUS "Activating global addon ${NAME_ADDON} with addon_config.cmake")
            include(${GLOBAL_ADDON_PATH}/${NAME_ADDON}.cmake)
        elseif (EXISTS ${OF_CMAKE_ADDONS}/${NAME_ADDON}.cmake)
            message(STATUS "Activating global addon ${NAME_ADDON} with ${NAME_ADDON}.cmake")
            include(${OF_CMAKE_ADDONS}/${NAME_ADDON}.cmake)
        else ()
            message(STATUS "Activating ${NAME_ADDON} via generic function. The generic function makes assumptions about the addon's file structure and is not guaranteed to work in all cases.")
            of_load_generic_addon(${GLOBAL_ADDON_PATH} ${NAME_ADDON})
        endif ()
    else ()
        message(STATUS "Addon ${NAME_ADDON} not found.")
    endif ()
endfunction()

# ---- activate Local addOn
#macro(OF_include_local_addOn NAME_ADDON)
#    set(GLOBAL_ADDON_PATH "${OF_DIRECTORY_ABSOLUTE}/addons/${NAME_ADDON}")
#    set(LOCAL_ADDON_PATH "${CMAKE_CURRENT_SOURCE_DIR}/${NAME_ADDON}")
#    set(ADDON_CONFIG ${OF_CMAKE_ADDONS}/external/${NAME_ADDON}.cmake)
#
#    if (EXISTS ${LOCAL_ADDON_PATH})
#        message(STATUS "Activating local addon from: ${LOCAL_ADDON_PATH}")
#        of_load_generic_addon(${LOCAL_ADDON_PATH} ${NAME_ADDON})
#    else ()
#        message(WARNING "Local addon ${NAME_ADDON} not found.")
#    endif ()
#endmacro()

# Attempts to load addons that do not have cmake files. Will work with basic addons that have a src directory.
# If there are libs that have sources, those will be compiled. It WILL NOT add any framework or static lib to
# the project path, however. You can either add a cmake file for that addon or import headers and libraries yourself
# in your projects CMakeFiles.txt
function(of_load_generic_addon ADDON_PATH NAME_ADDON)
    set(PATH_SRC ${ADDON_PATH}/src)
    set(PATH_LIBS ${ADDON_PATH}/libs)

    set(ADDON_SRC)

    file(GLOB_RECURSE OFX_ADDON_CPP "${PATH_SRC}/*.cpp")
    file(GLOB_RECURSE OFX_ADDON_CC "${PATH_SRC}/*.cc")
    file(GLOB_RECURSE OFX_ADDON_LIBS_CPP "${PATH_LIBS}/*.cpp")
    file(GLOB_RECURSE OFX_ADDON_LIBS_CC "${PATH_LIBS}/*.cc")
    list(APPEND ADDON_SRC ${OFX_ADDON_CPP} ${OFX_ADDON_CC} ${OFX_ADDON_LIBS_CPP} ${OFX_ADDON_LIBS_CC})

    list(LENGTH ADDON_SRC list_length)
    if (list_length EQUAL 0)
        message("List is empty")
    else ()
        message("Adding Library ${NAME_ADDON}")
        add_library(${NAME_ADDON} STATIC ${OFX_ADDON_CPP} ${OFX_ADDON_LIBS_CPP})
        target_link_libraries(${PROJECT_NAME} PRIVATE ${NAME_ADDON})

    endif ()

    OF_find_header_directories(HEADERS_SOURCE ${PATH_SRC})
    OF_find_header_directories(HEADERS_LIBS ${PATH_LIBS})
    #    message(STATUS ${HEADERS_SOURCE})
    #    message(STATUS "---")
    #    message(STATUS ${HEADERS_LIB})
    include_directories(${PATH_SRC})
    find_addon_include_dirs(${ADDON_PATH} ADDON_INCLUDE_DIRS)
    #    message(STATUS "Found include directories: ${ADDON_INCLUDE_DIRS}")
    include_directories(${ADDON_INCLUDE_DIRS})
endfunction()


function(find_addon_include_dirs ADDON_PATH OUT_INCLUDE_DIRS)
    set(INCLUDE_DIRS "")
    # Check if the 'libs' directory exists
    set(LIBS_PATH "${ADDON_PATH}/libs")
    if (NOT EXISTS ${LIBS_PATH})
        #        message(WARNING "No 'libs' directory found in ${ADDON_PATH}")
        set(${OUT_INCLUDE_DIRS} "" PARENT_SCOPE)
        return()
    endif ()

    # Loop through directories inside 'libs'
    file(GLOB LIB_DIRS LIST_DIRECTORIES true "${LIBS_PATH}/*")
    foreach (LIB_DIR ${LIB_DIRS})
        if (IS_DIRECTORY ${LIB_DIR})
            set(INCLUDE_PATH "${LIB_DIR}/include")

            # If 'include' directory exists, add it, otherwise add LIB_DIR itself
            if (EXISTS ${INCLUDE_PATH})
                list(APPEND INCLUDE_DIRS ${INCLUDE_PATH})
            else ()
                list(APPEND INCLUDE_DIRS ${LIB_DIR})
            endif ()
        endif ()
    endforeach ()

    # Return the list of include directories
    set(${OUT_INCLUDE_DIRS} "${INCLUDE_DIRS}" PARENT_SCOPE)
endfunction()
#==================================================================

# macro( OF_include_external_addOn NAME_ADDON )
#     if( ${NAME_ADDON} IN_LIST OFX_ADDONS_ACTIVE )
#         if( EXISTS ${OF_DIRECTORY_ABSOLUTE}/addons/${NAME_ADDON}/)
#             include( ${OF_CMAKE_ADDONS}/external/${NAME_ADDON}.cmake )
#             message( STATUS "${NAME_ADDON} activated" )
#         else()
#             message( WARNING "${NAME_ADDON} folder not found" )
#         endif()
#     endif()
# endmacro( OF_include_external_addOn )


# TODO Find also .hpp files
# ---- Find all include directories
function(of_find_header_directories return_list PATH)
    FILE(GLOB_RECURSE new_list ${PATH}/*.h)
    SET(dir_list "")
    FOREACH (file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list ${dir_list} ${dir_path})
    ENDFOREACH ()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${return_list} ${dir_list})
endfunction(of_find_header_directories)

#==================================================================

# TODO DOES NOT WORK YET
# ---- Find all source files
macro(of_find_source_files return_list PATH)
    file(GLOB_RECURSE FILES_CPP "${PATH}/*.cpp")
    file(GLOB_RECURSE FILES_CC "${PATH}/*.cc")
    file(GLOB_RECURSE FILES_C "${PATH}/*.c")
    set(${return_list} ${FILES_CPP} ${FILES_CC} ${FILES_C})
endmacro(of_find_source_files)

#==================================================================

function(of_add_xcframework_lib TARGET LIB_DIR_NAME)
    # Pick the right slice depending on platform
    set(XCF_PATH "${OF_DIRECTORY}/libs/${LIB_DIR_NAME}/lib/macos/${LIB_DIR_NAME}.xcframework")
    if (CMAKE_SYSTEM_NAME STREQUAL "iOS")
        if (CMAKE_OSX_ARCHITECTURES MATCHES "x86_64|arm64" AND CMAKE_OSX_SYSROOT MATCHES ".*Simulator")
            # iOS Simulator
            set(LIB_DIR "${XCF_PATH}/ios-arm64_x86_64-simulator")
        else ()
            # iOS Device
            set(LIB_DIR "${XCF_PATH}/ios-arm64")
        endif ()
    elseif (CMAKE_SYSTEM_NAME STREQUAL "Darwin")
        # macOS
        set(LIB_DIR "${XCF_PATH}/macos-arm64_x86_64")
    endif ()

    file(GLOB LIB_FILES "${LIB_DIR}/*.a")

    message(VERBOSE "Adding lib: ${LIB_FILES}")

    target_link_libraries(${TARGET} PUBLIC ${LIB_FILES})

    #   if (EXISTS "${LIB_DIR}/${LIB_NAME}.a")
    #       set(LIB_PATH "${LIB_DIR}/${LIB_NAME}.a")
    #   else ()
    #       set(LIB_PATH "${LIB_DIR}/lib${LIB_NAME}.a")
    #   endif ()
    #
    #   if (EXISTS ${LIB_PATH})
    #       target_link_libraries(${TARGET} PUBLIC ${LIB_PATH})
    #   else ()
    #       message(FATAL_ERROR "Could not find library ${LIB_NAME} in ${LIB_PATH}")
    #   endif ()

endfunction(of_add_xcframework_lib)

set(OF_APP_NAME)
set(MACOS_BUNDLE_ID "com.example.one")

macro(of_app APP_NAME SOURCE_FILES)
    set(OF_APP_NAME ${APP_NAME})
    if (APPLE)
        #        message(STATUS "${SOURCE_FILES}")
        add_executable(${APP_NAME} MACOSX_BUNDLE "${SOURCE_FILES}")
        #configure_file(
        #        "${CMAKE_SOURCE_DIR}/openFrameworks-Info.plist.in"
        #        "${CMAKE_SOURCE_DIR}/Info.plist"
        #        @ONLY
        #)

        set_target_properties(${APP_NAME} PROPERTIES
                #                      CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
                #                      CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
                MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOS_BUNDLE_ID}
                MACOSX_BUNDLE_INFO_PLIST ${CMAKE_SOURCE_DIR}/openFrameworks-Info.plist.in
                MACOSX_BUNDLE_BUNDLE_NAME ${APP_NAME}
        )
        #
        #set_target_properties(${APP_NAME} PROPERTIES
        #        MACOSX_BUNDLE TRUE
        #        MACOSX_BUNDLE_INFO_PLIST "${CMAKE_SOURCE_DIR}/Info.plist"
        #)

        #        target_link_libraries(${APP_NAME}
        #                ${OF_CORE_LIBS}
        #                of_static
        #                #        ${opengl_lib}
        #                ${OF_CORE_FRAMEWORKS}
        #                ${USER_LIBS}
        #                ${OF_ADDONS}

        #        add_custom_command(
        #                TARGET ${APP_NAME}
        #                POST_BUILD
        #                COMMAND rsync
        #                ARGS -aved ${OF_ROOT}/libs/fmod/lib/osx/libfmod.dylib "$<TARGET_FILE_DIR:${APP_NAME}>/../Frameworks/"
        #        )
        #
        #        add_custom_command(
        #                TARGET ${APP_NAME}
        #                POST_BUILD
        #                COMMAND ${CMAKE_INSTALL_NAME_TOOL}
        #                ARGS -change @executable_path/libfmod.dylib @executable_path/../Frameworks/libfmod.dylib $<TARGET_FILE:${APP_NAME}>
        #        )

    elseif (WIN32)
        add_executable(${APP_NAME} "${SOURCE_FILES}")
        target_compile_options(${APP_NAME} PUBLIC
                $<$<CONFIG:Debug>:/Od>
                $<$<CONFIG:Release>:/O2>
                -U__MINGW64__
                -U__MINGW32__)
        set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
        #        target_link_options(${APP_NAME} PUBLIC /DYNAMICBASE /MACHINE:X64 /NODEFAULTLIB:atlthunk.lib /NODEFAULTLIB:MSVCRT /NODEFAULTLIB:libcmt /NODEFAULTLIB:LIBC /NODEFAULTLIB:LIBCMTD /INCREMENTAL  /SUBSYSTEM:CONSOLE /NOLOGO )
        if (CMAKE_BUILD_TYPE MATCHES "Debug")
            target_link_options(${APP_NAME} PUBLIC /DEBUG /MACHINE:X64 /NODEFAULTLIB:"atlthunk.lib" /NODEFAULTLIB:"msvcrt" /NODEFAULTLIB:"libcmt" /NODEFAULTLIB:"LIBC" /NODEFAULTLIB:"LIBCMTD" /INCREMENTAL)
        else ()
            target_link_options(${APP_NAME} PUBLIC /DYNAMICBASE:NO /MACHINE:X64 /INCREMENTAL /SUBSYSTEM:CONSOLE /NOLOGO)
        endif ()
    endif ()

    target_link_libraries(${APP_NAME} PUBLIC of_static)

    # Add all addons as dependencies
    #    if (OF_ADDONS)
    #        add_dependencies( ${APP_NAME} ${OF_ADDONS} )
    #    endif ()

    set(OUTPUT_APP_NAME ${APP_NAME})
    if (CMAKE_BUILD_TYPE MATCHES Debug)
        set(OUTPUT_APP_NAME "${APP_NAME}_debug")
    endif ()

    set_target_properties(${APP_NAME}
            PROPERTIES
            RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
            OUTPUT_NAME ${OUTPUT_APP_NAME}
    )
endmacro()

function(of_print_list LIST)
    foreach (ITEM IN LISTS ${LIST})
        message(STATUS ${ITEM})
    endforeach ()
endfunction()

function(of_get_subdir_names result_var dir)
    # Get all children of dir
    file(GLOB children RELATIVE "${dir}" "${dir}/*")

    set(subdirs "")
    foreach (child ${children})
        if (IS_DIRECTORY "${dir}/${child}")
            list(APPEND subdirs "${child}")
        endif ()
    endforeach ()

    # Return result to caller scope
    set(${result_var} "${subdirs}" PARENT_SCOPE)
endfunction()

function(of_remove_debug_libs result_var the_list)
    set(filtered_list "")
    foreach (item IN LISTS the_list)
        get_filename_component(name "${item}" NAME) # e.g. libD.lib
        #        message(STATUS ${name})
        if (NOT name MATCHES "D.lib")
            list(APPEND filtered_list "${item}")
        endif ()
    endforeach ()
    set(${result_var} "${filtered_list}" PARENT_SCOPE)
endfunction()

