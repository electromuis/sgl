cmake_minimum_required(VERSION 3.0)




set_property(GLOBAL PROPERTY USE_FOLDERS ON)

# you need it to properly set variable from function() call
set(target_list "" CACHE INTERNAL "target_list")
function(add_library name)
    
    _add_library(${name} ${ARGN})

    if(NOT ${name} MATCHES "::")
        set(target_list ${target_list} ${name} CACHE INTERNAL "target_list")
    endif()
    
endfunction()

function(add_executable name)
    _add_executable(${name} ${ARGN})

    if(NOT ${name} MATCHES "::")
        set(target_list ${target_list} ${name} CACHE INTERNAL "target_list")
    endif()
endfunction()








project(sgl)

set(SGL_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}")
set(SGL_SRC_LIB_DEPS "${SGL_ROOT_DIR}/deps")

add_subdirectory(${SGL_SRC_LIB_DEPS})

add_subdirectory(cmake)
