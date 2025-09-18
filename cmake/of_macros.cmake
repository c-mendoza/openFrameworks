include_guard(GLOBAL)
include(of_detect)

#set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:Debug>DLL")
if (CMAKE_BUILD_TYPE STREQUAL "RelWithDebInfo" OR
        CMAKE_BUILD_TYPE STREQUAL "MinSizeRel")
    set(_CONFIG "Release")
else ()
    set(_CONFIG "${CMAKE_BUILD_TYPE}")
endif ()

function(ofIncludeAddon addonName)
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
    # Attempts to load addons that do not have cmake files. Will work with basic addons that have a src directory.
    # If there are libs that have sources, those will be compiled. It WILL NOT add any framework or static lib to
    # the project path, however. You can either add a cmake file for that addon or import headers and libraries yourself
    # in your projects CMakeFiles.txt
    function(of_load_generic_addon addonPath addonName)
        set(PATH_SRC ${addonPath}/src)
        set(PATH_LIBS ${addonPath}/libs)
        message(${addonPath})
        set(addonSrc)

        file(GLOB_RECURSE addonSrc
                "${PATH_SRC}/*.cpp"
                "${PATH_SRC}/*.cc"
                "${PATH_SRC}/*.c"
                #                "${PATH_LIBS}/*.cpp"
                #                "${PATH_LIBS}/*.cc"
                #                "${PATH_LIBS}/*.c"
        )

        #        file(GLOB_RECURSE addonLibsSrc
        #                "${PATH_LIBS}/*.cpp"
        #                "${PATH_LIBS}/*.cc")
        #        list(APPEND addonSrc ${OFX_ADDON_CPP}
        #                ${OFX_ADDON_LIBS_CPP})

        #    set(libs_subdirs)
        ofGetSubdirNames(libs_subdirs ${PATH_LIBS})

        list(LENGTH addonSrc list_length)
        if (list_length EQUAL 0)
            message("List is empty")
        else ()
            message("Addon ${addonName}")
            ofPrintList(addonSrc)
            add_library(${addonName} STATIC ${addonSrc})
            target_link_libraries(${OF_APP_NAME} PRIVATE ${addonName})
            add_dependencies(${OF_APP_NAME} ${addonName})
        endif ()

        foreach (item ${libs_subdirs})
            ofAddGenericLib(${PATH_LIBS}/${item} ${addonName})
        endforeach ()


        #        message("here: ${libs_subdirs}")

        ofFindHeaderDirectories(HEADERS_SOURCE ${PATH_SRC})
        ofFindHeaderDirectories(HEADERS_LIBS ${PATH_LIBS})
        #        message(STATUS ${HEADERS_SOURCE})
        #        message(STATUS "---")
        #        message(STATUS ${HEADERS_LIB})
        include_directories(${PATH_SRC})
        #        find_addon_include_dirs(${ADDON_PATH} ADDON_INCLUDE_DIRS)
        #        message(STATUS "Found include directories: ${ADDON_INCLUDE_DIRS}")
        #        include_directories(${ADDON_INCLUDE_DIRS})
    endfunction()

    set(globalAddonPath "${OF_DIRECTORY}/addons/${addonName}")
    set(localAddonPath "${CMAKE_CURRENT_SOURCE_DIR}/${addonName}")

    # Look for a local addon first
    if (EXISTS ${localAddonPath})
        #        message(STATUS "Activating local addon from: ${localAddonPath}")
        if (EXISTS ${localAddonPath}/addon_config.cmake)
            message(STATUS "Activating local addon ${addonName} with addon_config.cmake")
            include(${localAddonPath}/addon_config.cmake)
        else ()
            message(STATUS "Activating local addon ${addonName} via generic function. The generic function makes assumptions about the addon's file structure and is not guaranteed to work in all cases.")
            of_load_generic_addon(${localAddonPath} ${addonName})
        endif ()
        # Then look in the global addons
    elseif (EXISTS ${globalAddonPath})
        if (EXISTS ${globalAddonPath}/addon_config.cmake)
            message(STATUS "Activating global addon ${addonName} with addon_config.cmake")
            include(${globalAddonPath}/addon_config.cmake)
        else ()
            message(STATUS "Activating ${addonName} via generic function. The generic function makes assumptions about the addon's file structure and is not guaranteed to work in all cases.")
            of_load_generic_addon(${globalAddonPath} ${addonName})
        endif ()
    else ()
        message(STATUS "Addon ${addonName} not found.")
    endif ()
endfunction()


# Adds a library to the current OF_APP via a generic template.
# The function assumes that the library is in the format:
# libName
#  |___ include
#  |___ lib
#  |___ src
# It will link all lib files it finds in the /lib directory.
function(ofAddGenericLib path target)
    if (EXISTS ${path}/include)
        include_directories(${path}/include)
    endif ()
    if (EXISTS ${path}/lib)
        message(${path}/lib)
        if (OF_TARGET_MACOS)
#            message("KLASJHDKJASHD")
            file(GLOB theLibs
                    "${path}/lib/macos/*.a"
                    "${path}/lib/macos/*.xcframework"
            )
            message(STATUS ${theLibs})
            target_link_libraries(${target} PRIVATE ${theLibs})
        elseif (OF_TARGET_VS)
            file(GLOB winLibs
                    "${path}/lib/vs/x64/${_CONFIG}/*.lib"
            )
            #            message(STATUS ${winLibs})
            target_link_libraries(${target} PRIVATE ${winLibs})

        endif ()
    endif ()
    if (EXISTS ${path}/src)
        include_directories(${path}/src)
        file(GLOB_RECURSE libSources
                "${path}/src/*.cpp"
                "${path}/src/*.cc"
                "${path}/src/*.c"
        )
        target_sources(${target} PUBLIC ${libSources})
    endif ()
endfunction()


# TODO Find also .hpp files
# ---- Find all include directories
function(ofFindHeaderDirectories return_list PATH)
    FILE(GLOB_RECURSE new_list ${PATH}/*.h)
    SET(dir_list "")
    FOREACH (file_path ${new_list})
        GET_FILENAME_COMPONENT(dir_path ${file_path} PATH)
        SET(dir_list ${dir_list} ${dir_path})
    ENDFOREACH ()
    LIST(REMOVE_DUPLICATES dir_list)
    SET(${return_list} ${dir_list})
endfunction(ofFindHeaderDirectories)

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
set(OF_MACOS_BUNDLE_ID "com.example.one")

macro(ofApp APP_NAME SOURCE_FILES)
    ofDetectTarget()
    set(OF_APP_NAME ${APP_NAME})
    set(OUTPUT_APP_NAME ${APP_NAME})
    if (CMAKE_BUILD_TYPE MATCHES Debug)
        set(OUTPUT_APP_NAME "${APP_NAME}_debug")
    endif ()

    if (APPLE)
        set(PLIST_TEMPLATE "${OF_DIRECTORY}/cmake/MacOSXBundleInfo.plist.in")
        set(PLIST_OUT "${CMAKE_BINARY_DIR}/MacOSXBundleInfo.plist")

        configure_file(${PLIST_TEMPLATE} ${PLIST_OUT})
        add_executable(${APP_NAME} MACOSX_BUNDLE "${SOURCE_FILES}")
        set_target_properties(${APP_NAME} PROPERTIES
                MACOSX_BUNDLE TRUE
                MACOSX_BUNDLE_INFO_PLIST ${PLIST_OUT}
                CMAKE_XCODE_ATTRIBUTE_CODE_SIGN_IDENTITY ""
                CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO"
                RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
                OUTPUT_NAME ${OUTPUT_APP_NAME}
                #                MACOSX_BUNDLE_GUI_IDENTIFIER ${MACOS_BUNDLE_ID}
        )

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
                #                $<$<CONFIG:Debug>:/Od /Zl /D _DEBUG>
                $<$<CONFIG:Debug>:/Od /Zl>
                $<$<CONFIG:Release>:/O2>
                -U__MINGW64__
                -U__MINGW32__)
        #        target_link_options(${APP_NAME} PUBLIC /DYNAMICBASE /MACHINE:X64 /NODEFAULTLIB:atlthunk.lib /NODEFAULTLIB:MSVCRT /NODEFAULTLIB:libcmt /NODEFAULTLIB:LIBC /NODEFAULTLIB:LIBCMTD /INCREMENTAL  /SUBSYSTEM:CONSOLE /NOLOGO )
        #        target_link_options(${APP_NAME} PUBLIC /DEBUG /MACHINE:X64 /NODEFAULTLIB:"atlthunk.lib" /NODEFAULTLIB:"msvcrt" /NODEFAULTLIB:"libcmt" /NODEFAULTLIB:"LIBC" /NODEFAULTLIB:"LIBCMTD" /INCREMENTAL)

        if (CMAKE_BUILD_TYPE MATCHES "Debug")
            target_link_options(${APP_NAME} PUBLIC /MACHINE:X64 /INCREMENTAL)
        else ()
            target_link_options(${APP_NAME} PUBLIC /DYNAMICBASE:NO /MACHINE:X64 /INCREMENTAL /SUBSYSTEM:CONSOLE /NOLOGO /TLBID:1)
        endif ()
        set_target_properties(${APP_NAME}
                PROPERTIES
                RUNTIME_OUTPUT_DIRECTORY ${CMAKE_SOURCE_DIR}/bin
                OUTPUT_NAME ${OUTPUT_APP_NAME}
        )
    endif ()

    target_link_libraries(${APP_NAME} PUBLIC of_static)

    # Add all addons as dependencies
    #    if (OF_ADDONS)
    #        add_dependencies( ${APP_NAME} ${OF_ADDONS} )
    #    endif ()


endmacro()

function(ofPrintList LIST)
    foreach (ITEM IN LISTS ${LIST})
        message(STATUS ${ITEM})
    endforeach ()
endfunction()

function(ofGetSubdirNames result_var dir)
    # Get all children of dir
    file(GLOB children RELATIVE "${dir}" "${dir}/*")

    set(subdirs "")
    foreach (child ${children})
        if (IS_DIRECTORY "${dir}/${child}")
            list(APPEND subdirs "${child}")
        endif ()
    endforeach ()

    #    message(${subdirs})
    # Return result to caller scope
    set(${result_var} ${subdirs} PARENT_SCOPE)
endfunction()

#function(ofRemoveDebugLibs result_var the_list)
#    set(filtered_list "")
#    foreach (item IN LISTS the_list)
#        get_filename_component(name "${item}" NAME) # e.g. libD.lib
#        #        message(STATUS ${name})
#        if (NOT name MATCHES "D.lib")
#            list(APPEND filtered_list "${item}")
#        endif ()
#    endforeach ()
#    set(${result_var} "${filtered_list}" PARENT_SCOPE)
#endfunction()

