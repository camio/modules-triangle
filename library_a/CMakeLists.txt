cmake_minimum_required(VERSION 3.30)
project(library_a LANGUAGES CXX)

add_library(library_a STATIC)
target_sources(library_a
    PUBLIC
        FILE_SET CXX_MODULES FILES
            modules/library_a.cppm
    PRIVATE
        src/library_a.cpp
)
target_link_libraries(library_a PUBLIC library_b library_c)
target_compile_features(library_a PUBLIC cxx_std_23)
