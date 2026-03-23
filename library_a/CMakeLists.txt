cmake_minimum_required(VERSION 3.30...4.3)

project(library_a LANGUAGES CXX)

add_library(library_a STATIC)
add_library(abc::library_a ALIAS library_a)
target_sources(
    library_a
    PUBLIC FILE_SET CXX_MODULES FILES modules/library_a.cppm
    PRIVATE src/library_a.cpp
)
target_link_libraries(library_a PUBLIC library_b library_c)
target_compile_features(library_a PUBLIC cxx_std_23)
if(CMAKE_CXX_MODULE_STD)
    message(STATUS "Build abc with target PROPERTY CXX_MODULE_STD ON")
    set_property(TARGET library_a PROPERTY CXX_MODULE_STD ON)
    target_compile_definitions(library_a PUBLIC ABC_HAS_IMPORT_STD)
endif()
