cmake_minimum_required(VERSION 3.30...4.3)

project(library_b LANGUAGES CXX)

add_library(library_b STATIC)
add_library(abc::library_b ALIAS library_b)
target_sources(
    library_b
    PUBLIC
        FILE_SET HEADERS BASE_DIRS include FILES include/library_b/library_b.hpp
    PRIVATE src/library_b.cpp
)
target_link_libraries(library_b PUBLIC library_c)
target_compile_features(library_b PUBLIC cxx_std_23)
