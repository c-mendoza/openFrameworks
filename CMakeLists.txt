cmake_minimum_required(VERSION 3.28)
set(CMAKE_MSVC_RUNTIME_LIBRARY "MultiThreaded$<$<CONFIG:Debug>:>DLL")

#if (CMAKE_CURRENT_LIST_DIR STREQUAL CMAKE_SOURCE_DIR)
    project(openFrameworks)
#endif()

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/cmake")
set(OF_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})
include(of_macros)

# --------------------------------------------------
# Installation prefix: {OF_DIRECTORY}/install/{platform}
# --------------------------------------------------
#ofSetInstallPrefix()
# --------------------------------------------------
# Source Files
# --------------------------------------------------

file(GLOB_RECURSE SRC_3D "${OF_DIRECTORY}/libs/openFrameworks/3d/*.cpp")
set(SRC_APP
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofAppGLFWWindow.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofBaseApp.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofAppNoWindow.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofAppRunner.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/app/ofMainLoop.cpp
)
file(GLOB_RECURSE SRC_COMMS "${OF_DIRECTORY}/libs/openFrameworks/communication/*.cpp")
file(GLOB_RECURSE SRC_EVENTS "${OF_DIRECTORY}/libs/openFrameworks/events/*.cpp")
file(GLOB_RECURSE SRC_GRAPHICS "${OF_DIRECTORY}/libs/openFrameworks/graphics/*.cpp")
file(GLOB_RECURSE SRC_GL "${OF_DIRECTORY}/libs/openFrameworks/gl/*.cpp")
file(GLOB_RECURSE SRC_MATH "${OF_DIRECTORY}/libs/openFrameworks/math/*.cpp")
set(SRC_SOUND
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofFmodSoundPlayer.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofOpenALSoundPlayer.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundBuffer.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundPlayer.cpp
)
file(GLOB_RECURSE SRC_TYPES "${OF_DIRECTORY}/libs/openFrameworks/types/*.cpp")
file(GLOB_RECURSE SRC_UTILS "${OF_DIRECTORY}/libs/openFrameworks/utils/*.cpp")
set(SRC_VIDEO
        ${OF_DIRECTORY}/libs/openFrameworks/video/ofVideoGrabber.cpp
        ${OF_DIRECTORY}/libs/openFrameworks/video/ofVideoPlayer.cpp
)

set(OF_SRC)

list(APPEND OF_SRC
        ${SRC_3D}
        ${SRC_APP}
        ${SRC_COMMS}
        ${SRC_EVENTS}
        ${SRC_GRAPHICS}
        ${SRC_GL}
        ${SRC_MATH}
        ${SRC_SOUND}
        ${SRC_TYPES}
        ${SRC_UTILS}
        ${SRC_VIDEO}
)

# --------------------------------------------------
# Append platform specific files
# --------------------------------------------------

if (APPLE)
    list(APPEND OF_SRC
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofSoundStream.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofAVFoundationVideoPlayer.m
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofAVFoundationPlayer.mm
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofAVFoundationGrabber.mm
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofAVEngineSoundPlayer.h
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofAVEngineSoundPlayer.mm
    )
elseif (WIN32)
    list(APPEND OF_SRC
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofDirectShowGrabber.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofDirectShowPlayer.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/video/ofMediaFoundationPlayer.cpp
            ${OF_DIRECTORY}/libs/openFrameworks/sound/ofMediaFoundationSoundPlayer.cpp
    )
endif ()

#foreach (item IN LISTS OF_SRC)
#    message(STATUS " - ${item}")
#endforeach ()

# --------------------------------------------------
# Target
# --------------------------------------------------

add_library(of_static STATIC ${OF_SRC})

# --------------------------------------------------
# Export & Install
# --------------------------------------------------

include(CMakePackageConfigHelpers)

# Export target for downstream apps
install(TARGETS of_static
        EXPORT openFrameworksTargets
        ARCHIVE DESTINATION lib
        LIBRARY DESTINATION lib
        RUNTIME DESTINATION bin
)

# Install openFrameworks headers
install(DIRECTORY libs/openFrameworks
        DESTINATION include
        FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.inl"
)

# Install 3rd-party headers
set(OF_LIB_NAMES
        brotli
        cairo
        curl
        fmt
        FreeImage
        freetype
        glew
        glfw
        glm
        json
        libpng
        libusb
        openssl
        pixman
        pugixml
        rtAudio
        tess2
        uriparser
        utf8
        zlib
)

foreach(dir ${OF_LIB_NAMES})
    install(DIRECTORY libs/${dir}/include/   # <-- note trailing slash
            DESTINATION include/
            FILES_MATCHING PATTERN "*.h" PATTERN "*.hpp" PATTERN "*.inl")
endforeach()

add_custom_target(build_and_install
        COMMAND ${CMAKE_COMMAND} --build ${CMAKE_BINARY_DIR} --target install
        DEPENDS of_static
)

# Export targets
install(EXPORT openFrameworksTargets
        FILE openFrameworksTargets.cmake
        NAMESPACE openFrameworks::
        DESTINATION lib/cmake/openFrameworks
)

# Generate the config file
configure_package_config_file(
        ${CMAKE_CURRENT_LIST_DIR}/cmake/openFrameworksConfig.cmake.in
        ${CMAKE_CURRENT_BINARY_DIR}/openFrameworksConfig.cmake
        INSTALL_DESTINATION lib/cmake/openFrameworks
)

install(FILES
        ${CMAKE_CURRENT_BINARY_DIR}/openFrameworksConfig.cmake
        DESTINATION lib/cmake/openFrameworks
)

# These don't seem to work
set_target_properties(of_static PROPERTIES
        OUTPUT_NAME "openframeworksLib$<$<CONFIG:Debug>:_debug>"
        CXX_STANDARD 20
        CXX_STANDARD_REQUIRED ON
        C_STANDARD 17
        C_STANDARD_REQUIRED ON
)

add_custom_command(TARGET of_static POST_BUILD
        COMMAND ${CMAKE_COMMAND} --install ${CMAKE_BINARY_DIR}
        COMMENT "Installing openFrameworks after build"
)

if (OF_TARGET_MACOS)
    # These don't seem to work
    set_target_properties(of_static PROPERTIES
            OBJCXX_STANDARD 20
            OBJC_STANDARD 17
    )
endif ()

# This seems to be the only thing that sets the c++ standard...
set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_C_STANDARD 17)
set(CMAKE_C_STANDARD_REQUIRED ON)


# -------------------------------------------------- #
# Includes                                           #
# -------------------------------------------------- #


set(OF_HEADERS
        ${OF_DIRECTORY}/libs/openFrameworks/
        ${OF_DIRECTORY}/libs/openFrameworks/3d
        ${OF_DIRECTORY}/libs/openFrameworks/app
        ${OF_DIRECTORY}/libs/openFrameworks/communication
        ${OF_DIRECTORY}/libs/openFrameworks/events
        ${OF_DIRECTORY}/libs/openFrameworks/events
        ${OF_DIRECTORY}/libs/openFrameworks/gl
        ${OF_DIRECTORY}/libs/openFrameworks/graphics
        ${OF_DIRECTORY}/libs/openFrameworks/math
        ${OF_DIRECTORY}/libs/openFrameworks/sound
        ${OF_DIRECTORY}/libs/openFrameworks/types
        ${OF_DIRECTORY}/libs/openFrameworks/utils
        ${OF_DIRECTORY}/libs/openFrameworks/video
        ${OF_DIRECTORY}/libs/brotli/include
        ${OF_DIRECTORY}/libs/cairo/include
        ${OF_DIRECTORY}/libs/curl/include
        ${OF_DIRECTORY}/libs/fmt/include
        ${OF_DIRECTORY}/libs/FreeImage/include
        ${OF_DIRECTORY}/libs/freetype/include
        ${OF_DIRECTORY}/libs/FreeImage/include
        ${OF_DIRECTORY}/libs/glew/include
        ${OF_DIRECTORY}/libs/glfw/include
        ${OF_DIRECTORY}/libs/glm/include
        ${OF_DIRECTORY}/libs/json/include
        ${OF_DIRECTORY}/libs/libpng/include
        ${OF_DIRECTORY}/libs/libusb/include
        ${OF_DIRECTORY}/libs/openssl/include
        ${OF_DIRECTORY}/libs/pixman/include
        ${OF_DIRECTORY}/libs/pugixml/include
        ${OF_DIRECTORY}/libs/rtAudio/include
        ${OF_DIRECTORY}/libs/tess2/include
        ${OF_DIRECTORY}/libs/uriparser/include
        ${OF_DIRECTORY}/libs/utf8/include
        ${OF_DIRECTORY}/libs/zlib/include
)

#include_directories(${OF_HEADERS})

target_include_directories(of_static
        PUBLIC
        $<BUILD_INTERFACE:${OF_HEADERS}>
#        $<INSTALL_INTERFACE:include>
        $<INSTALL_INTERFACE:${CMAKE_INSTALL_PREFIX}/include>

)
# --------------------------------------------------
# Libraries
# --------------------------------------------------

if (OF_TARGET_MACOS)
    foreach (ITEM ${OF_LIB_NAMES})
        set(XCF_PATH "${OF_DIRECTORY}/libs/${ITEM}/lib/macos/${ITEM}.xcframework")
        # Some libs are include-only, so check if the xcframework exists
        if (EXISTS ${XCF_PATH})
            target_link_libraries(of_static PUBLIC ${XCF_PATH})
        endif ()
    endforeach ()


    find_library(accelerate_lib Accelerate)
    find_library(iokit_lib IOKit)
    find_library(agl_lib AGL)
    find_library(applicationservices_lib ApplicationServices)
    find_library(audiotoolbox_lib AudioToolbox)
    find_library(coreaudio_lib CoreAudio)
    find_library(corefoundation_lib CoreFoundation)
    find_library(coreservices_lib CoreServices)
    find_library(opengl_lib OpenGL)
    # find_library(quicktime_lib QuickTime)
    find_library(corevideo_lib CoreVideo)
    find_library(qtkit_lib QTKit)
    find_library(cocoa_lib Cocoa)
    find_library(coremedia_lib CoreMedia)
    find_library(avfoundation_lib AVFoundation)
    find_library(quartzcore_lib QuartzCore)
    find_library(appkit_lib AppKit)
    find_library(security_lib Security)
    find_library(ldap_lib LDAP)
    find_library(sys_conf SystemConfiguration)

    set(OF_FRAMEWORKS
            ${accelerate_lib}
            ${iokit_lib}
            ${agl_lib}
            ${applicationservices_lib}
            ${audiotoolbox_lib}
            ${coreaudio_lib}
            ${corefoundation_lib}
            ${coreservices_lib}
            ${opengl_lib}
            ${quicktime_lib}
            ${corevideo_lib}
            ${qtkit_lib}
            ${cocoa_lib}
            ${coremedia_lib}
            ${avfoundation_lib}
            ${quartzcore_lib}
            ${appkit_lib}
            ${security_lib}
            ${ldap_lib}
            ${sys_conf}
    )

    target_link_libraries(of_static PUBLIC ${OF_FRAMEWORKS})

elseif (OF_TARGET_VS)
    set(OF_LIB_DIRS)
    set(OF_LIB_FILES
            brotlicommon.lib
            brotlidec.lib
            brotlienc.lib
            libcairo.lib
            libcurl.lib
            fmt.lib
            #            FreeImage$<$<CONFIG:Debug>:D>.lib
            FreeImage.lib
            #            freetype$<$<CONFIG:Debug>:d>.lib
            freetype.lib
            libglew32.lib
            glfw3.lib
            libpng.lib
            libcrypto.lib
            libssl.lib
            libpixman-1.lib
            #            pugixml$<$<CONFIG:Debug>:D>.lib
            pugixml.lib
            #            rtaudio$<$<CONFIG:Debug>:D>.lib
            rtaudio.lib
            tess2.lib
            uriparser.lib
            #            videoInput$<$<CONFIG:Debug>:D>.lib
            videoInput.lib
            zlib.lib
    )

    #    message(STATUS ${OF_LIB_FILES})
    set(WIN_ARCH "x64")
    list(APPEND OF_LIB_NAMES "videoInput")
    include_directories(${OF_DIRECTORY}/libs/videoInput/include)


    set(FOUND_LIBS)
    foreach (LIB ${OF_LIB_NAMES})
        set(LIB_DIR "${OF_DIRECTORY}/libs/${LIB}/lib/vs/${WIN_ARCH}")
        list(APPEND OF_LIB_DIRS ${LIB_DIR})
    endforeach ()
    target_link_directories(of_static PUBLIC ${OF_LIB_DIRS})

    target_link_libraries(of_static PUBLIC ${OF_LIB_FILES})
    #
    #        message(STATUS "Searching for ${LIB} in ${LIB_DIR}")
    #
    #        find_library(found_lib_${LIB} NAMES ${LIB} PATHS ${LIB_DIR} NO_DEFAULT_PATH)
    #
    #        if (found_lib)
    #            message(STATUS "Found: ${found_lib_${LIB}}")
    #            list(APPEND FOUND_LIBS ${found_lib_${LIB}})
    #        else ()
    #            message(WARNING "Library ${LIB} not found in ${LIB_DIR}")
    #        endif ()


    #        set(LIB_DIR ${OF_DIRECTORY}/libs/${LIB}/lib/vs/${WIN_ARCH})
    #        file(GLOB LIB_FILES "${LIB_DIR}/*.lib")
    #        list(LENGTH LIB_FILES len)
    #        if (len GREATER 0)
    #            of_remove_debug_libs(LIB_FILES_NO_D "${LIB_FILES}")
    #            target_link_libraries(of_static PUBLIC ${LIB_FILES_NO_D})
    #        endif ()

    #    endforeach ()

    message(STATUS ${FOUND_LIBS})
    set(OF_WIN_SYSTEM_LIBS msimg32 OpenGL32 kernel32 setupapi Vfw32 comctl32 dsound user32 gdi32 winspool comdlg32 advapi32 shell32 ole32 oleaut32 uuid iphlpapi crypt32 Ws2_32 winmm odbc32 odbccp32 wldap32 mf mfplat mfuuid d3d11 mfreadwrite xaudio2 ucrt)
    target_link_libraries(of_static PUBLIC ${OF_WIN_SYSTEM_LIBS})
endif ()

#target_link_libraries(of_static PUBLIC ${OF_ADDON_FRAMEWORKS} ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS})
# target_link_libraries(of_shared ${OF_ADDON_FRAMEWORKS} ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS} )

# -------------------------------- Properties --------------------------------


# --------------------------------------------------
# Compilation options
# --------------------------------------------------


if (OF_TARGET_MACOS)
    set_source_files_properties(${OF_SRC} PROPERTIES
            COMPILE_FLAGS "-fobjc-arc")
    target_compile_options(of_static PUBLIC
            $<$<CONFIG:Debug>:-O0>
            $<$<CONFIG:Release>:-O3>
            $<$<COMPILE_LANGUAGE:CXX>:-std=c++20 -stdlib=libc++ -fobjc-arc -x objective-c++>
            $<$<COMPILE_LANGUAGE:C>:-x objective-c>
            -Wno-deprecated-declarations
    )
    target_compile_definitions(of_static PUBLIC __MACOSX_CORE__)

elseif (OF_TARGET_VS)
    target_compile_definitions(of_static PUBLIC
            WIN32 CURL_STATICLIB URI_STATIC_BUILD _HAS_STREAM_INSERTION_OPERATORS_DELETED_IN_CXX20 _CONSOLE POCO_STATIC CAIRO_WIN32_STATIC_BUILD DISABLE_SOME_FLOATING_POINT OF_NO_FMOD GLM_FORCE_CTOR_INIT GLM_ENABLE_EXPERIMENTAL _UNICODE UNICODE FREEIMAGE_LIB ) # GLEW_STATIC
    target_compile_options(of_static PUBLIC
            #            $<$<CONFIG:Debug>:/D _DEBUG>
            $<$<CONFIG:Debug>:/Od /Zl>
            $<$<CONFIG:Release>:/O2>
            $<$<COMPILE_LANGUAGE:CXX>:/std:c++20>
            $<$<COMPILE_LANGUAGE:C>:/std:c17>
            /Gm-
            /WX- /Zc:forScope /Gd /FC /EHsc /nologo /Zc:__cplusplus /Zc:inline /Zc:wchar_t /W3 /fp:precise)
    target_link_options(of_static PUBLIC /MACHINE:X64 /NOLOGO)

endif ()





