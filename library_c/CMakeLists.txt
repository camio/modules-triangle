cmake_minimum_required(VERSION 3.30...4.3)

project(library_c LANGUAGES CXX)

option(LIBRARY_C_MODULES "Build library_c with C++20 module support" ON)

if(LIBRARY_C_MODULES)
    set(LIBRARY_C_ENABLE_MODULE_SUPPORT 1)
endif()

configure_file(
    include/library_c/config.hpp.in
    "${CMAKE_CURRENT_BINARY_DIR}/include/library_c/config.hpp"
)

if(LIBRARY_C_MODULES)
    add_library(library_c STATIC)
    target_sources(
        library_c
        PUBLIC FILE_SET CXX_MODULES FILES modules/library_c.cppm
        PUBLIC
            FILE_SET HEADERS
                BASE_DIRS include "${CMAKE_CURRENT_BINARY_DIR}/include"
                FILES
                    include/library_c/library_c.hpp
                    "${CMAKE_CURRENT_BINARY_DIR}/include/library_c/config.hpp"
        PRIVATE src/library_c.cppm.cpp src/library_c_impl.hpp
    )
    target_compile_features(library_c PUBLIC cxx_std_23)
    if(CMAKE_CXX_MODULE_STD)
        message(STATUS "Build abc with target PROPERTY CXX_MODULE_STD ON")
        set_property(TARGET library_c PROPERTY CXX_MODULE_STD ON)
        target_compile_definitions(library_c PUBLIC ABC_HAS_IMPORT_STD)
    endif()
else()
    add_library(library_c STATIC)
    target_sources(
        library_c
        PUBLIC
            FILE_SET HEADERS
                BASE_DIRS include "${CMAKE_CURRENT_BINARY_DIR}/include"
                FILES
                    include/library_c/library_c.hpp
                    "${CMAKE_CURRENT_BINARY_DIR}/include/library_c/config.hpp"
        PRIVATE src/library_c.cpp src/library_c_impl.hpp
    )
    target_compile_features(library_c PUBLIC cxx_std_23)
endif()

add_library(abc::library_c ALIAS library_c)
