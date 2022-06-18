set(FFmpeg_dev_md5 "2788ff871ba1c1b91b6f0e91633bef2a")
set(FFmpeg_shared_md5 "beb39d523cdb032b59f81db80b020f31")
set(FFmpeg_dev_url    "https://data.kitware.com/api/v1/file/5c520afc8d777f072b212cca/download/ffmpeg-3.3.3-win64-dev.zip")
set(FFmpeg_shared_url "https://data.kitware.com/api/v1/file/5c520b068d777f072b212cd4/download/ffmpeg-3.3.3-win64-shared.zip")
include(FetchContent)

if (WIN32)
  # On windows, FFMPEG relies on prebuilt binaries. These binaries come in two
  # archives, dev and shared. An external project is added for each of them just
  # for the download.
  # The FFmpeg external project then takes care of combining the dev and shared
  # binaries into the install directory using the Patches/FFmpeg/Install.cmake
  # script.
  FetchContent_Declare(FFmpeg_dev
    URL ${FFmpeg_dev_url}
    URL_MD5 ${FFmpeg_dev_md5})
  FetchContent_MakeAvailable(FFmpeg_dev)
  list(APPEND CMAKE_PREFIX_PATH "${ffmpeg_dev_SOURCE_DIR}")

  FetchContent_Declare(FFmpeg_shared
    URL ${FFmpeg_shared_url}
    URL_MD5 ${FFmpeg_shared_md5})
  FetchContent_MakeAvailable(FFmpeg_shared)
  list(APPEND CMAKE_PREFIX_PATH "${ffmpeg_shared_SOURCE_DIR}")

  include("FindFFmpeg.cmake")

else ()
  include(External_yasm)
  set(fletch_YASM ${fletch_BUILD_PREFIX}/src/yasm-build/yasm)
  set(_FFmpeg_yasm --yasmexe=${fletch_YASM})
  list(APPEND ffmpeg_DEPENDS yasm)

  # Should we try to point ffmpeg at zlib if we are building it?
  # Currently it uses the system version.
  if (fletch_ENABLE_Zlib)
    list(APPEND ffmpeg_DEPENDS ZLib)
  endif()

  set (FFmpeg_patch ${fletch_SOURCE_DIR}/Patches/FFmpeg/${_FFmpeg_version})
  if (EXISTS ${FFmpeg_patch})
    set(FFMPEG_PATCH_COMMAND ${CMAKE_COMMAND}
      -DFFmpeg_patch:PATH=${FFmpeg_patch}
      -DFFmpeg_source:PATH=${fletch_BUILD_PREFIX}/src/FFmpeg
      -P ${FFmpeg_patch}/Patch.cmake
      )
  else()
    set(FFMPEG_PATCH_COMMAND "")
  endif()

  if (BUILD_SHARED_LIBS)
    set(_shared_lib_params --enable-shared --disable-static)
  else()
    set(_shared_lib_params --disable-shared
                           --enable-static
                           --enable-pic
                           --extra-cflags=-fPIC
                           --extra-cxxflags=-fPIC
                           --disable-asm
       )
  endif()
  set(FFMPEG_CONFIGURE_COMMAND
    ${fletch_BUILD_PREFIX}/src/FFmpeg/configure
    --prefix=${fletch_BUILD_INSTALL_PREFIX}
    --enable-runtime-cpudetect
    ${_FFmpeg_yasm}
    ${_FFmpeg_zlib}
    ${_shared_lib_params}
    --cc=${CMAKE_C_COMPILER}
    --cxx=${CMAKE_CXX_COMPILER}
    --enable-rpath
    )

  if (_FFmpeg_version VERSION_LESS 3.3.0)
    # memalign-hack is only needed for windows and older versions of ffmpeg
    list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-memalign-hack)
    # bzlib errors if not found in newer versions (previously it did not)
    list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-bzlib)
    list(APPEND FFMPEG_CONFIGURE_COMMAND --enable-outdev=sdl)
  endif()

  if(APPLE)
    list(APPEND FFMPEG_CONFIGURE_COMMAND --sysroot=${CMAKE_OSX_SYSROOT} --disable-doc)
  endif()


  Fletch_Require_Make()
  ExternalProject_Add(FFmpeg
    URL ${FFmpeg_file}
    DEPENDS ${ffmpeg_DEPENDS}
    URL_MD5 ${FFmpeg_md5}
    ${COMMON_EP_ARGS}
    PATCH_COMMAND ${FFMPEG_PATCH_COMMAND}
    CONFIGURE_COMMAND ${FFMPEG_CONFIGURE_COMMAND}
    BUILD_COMMAND ${MAKE_EXECUTABLE}
    INSTALL_COMMAND ${MAKE_EXECUTABLE} install
    )
  fletch_external_project_force_install(PACKAGE FFmpeg)
endif ()