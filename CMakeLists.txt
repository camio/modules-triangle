cmake_minimum_required(VERSION 4.2...4.3)

#======================================================================
# 1. Enable experimental 'import std;' support
#======================================================================
# gersemi: off
if(NOT DEFINED CMAKE_EXPERIMENTAL_CXX_IMPORT_STD)
    if(CMAKE_VERSION VERSION_GREATER_EQUAL 4.3 AND CMAKE_VERSION VERSION_LESS 4.4)
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "451f2fe2-a8a2-47c3-bc32-94786d8fc91b")
    elseif(CMAKE_VERSION VERSION_GREATER_EQUAL 4.2 AND CMAKE_VERSION VERSION_LESS 4.3)
        set(CMAKE_EXPERIMENTAL_CXX_IMPORT_STD "d0edc3af-4c50-42ea-a356-e2862fe7a444")
    elseif(CMAKE_VERSION VERSION_GREATER 4.3)
        message( WARNING "This version of CMake has not been tested for 'import std;'.")
    endif()
endif()
# gersemi: on

project(modules_triangle VERSION 0.1.0 LANGUAGES CXX)

#======================================================================
# Check if import std; is available for the current toolchain
#======================================================================
if(${CMAKE_CXX_STANDARD} IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
    set(CMAKE_CXX_MODULE_STD 1)
    message(STATUS "Using `import std;`")
else()
    message(
        WARNING
        "`import std;` is not available for C++${CMAKE_CXX_STANDARD}"
    )
    set(CMAKE_CXX_MODULE_STD)
endif()

add_subdirectory(library_c)
add_subdirectory(library_b)
add_subdirectory(library_a)

#======================================================================
# tests
#======================================================================
enable_testing()
add_subdirectory(tests)

#======================================================================
# install
#======================================================================
include(cmake/boost-install-library.cmake)
boost_install_library(modules_triangle TARGETS library_c library_b library_a NAMESPACE abc)
