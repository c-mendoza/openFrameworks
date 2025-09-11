## openFrameworks
cmake_minimum_required(VERSION 3.16)

project(openFrameworks)
set(OF_DIRECTORY ${CMAKE_CURRENT_LIST_DIR})

include(${OF_DIRECTORY}/cmake/of_macros.cmake)

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
endif ()

#foreach (item IN LISTS OF_SRC)
#    message(STATUS " - ${item}")
#endforeach ()

# --------------------------------------------------
# Target
# --------------------------------------------------

add_library(of_static STATIC ${OF_SRC})
set_target_properties(of_static PROPERTIES OUTPUT_NAME openFrameworks)

# --------------------------------------------------
# Includes
# --------------------------------------------------

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

include_directories(${OF_HEADERS})

# --------------------------------------------------
# Libraries
# --------------------------------------------------

if (APPLE)
    foreach (ITEM ${OF_LIB_NAMES})
        of_add_xcframework_lib(of_static ${ITEM})
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

endif ()

#target_link_libraries(of_static PUBLIC ${OF_ADDON_FRAMEWORKS} ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS})
# target_link_libraries(of_shared ${OF_ADDON_FRAMEWORKS} ${OF_CORE_LIBS} ${OF_CORE_FRAMEWORKS} )

# -------------------------------- Properties --------------------------------


# --------------------------------------------------
# Compilation options
# --------------------------------------------------

if (APPLE)
    set(CMAKE_C_FLAGS "-x objective-c") # -x objective-c
    set(CMAKE_CXX_FLAGS "-std=c++17 -stdlib=libc++ -D__MACOSX_CORE__ -fobjc-arc") # Removed "-stdlib=libstdc++
    set_source_files_properties(${OF_SRC} PROPERTIES COMPILE_FLAGS "-x objective-c++")
    add_compile_options(-Wno-deprecated-declarations)
endif ()





