# FFMpeg
if (WIN32)
    include("External_FFmpeg.cmake")
endif ()


# FModex
include(${SGL_SRC_LIB_DEPS}/fmodex/CMakeLists.txt)

# SDL 2
add_subdirectory(${SGL_SRC_LIB_DEPS}/sdl2)
include_directories(${SGL_SRC_LIB_DEPS}/sdl2-ttf)

# SDL 2 Image
add_subdirectory(${SGL_SRC_LIB_DEPS}/sdl2-image)

# SDL 2 Ttf
add_subdirectory(${SGL_SRC_LIB_DEPS}/freetype)
add_library(Freetype::Freetype ALIAS freetype)
add_subdirectory(${SGL_SRC_LIB_DEPS}/sdl2-ttf)


#set_target_properties(${target_list} PROPERTIES FOLDER "External Projects")
set(target_list "" CACHE INTERNAL "target_list")