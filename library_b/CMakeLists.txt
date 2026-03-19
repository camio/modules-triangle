cmake_minimum_required(VERSION 3.30)
project(library_b LANGUAGES CXX)

add_library(library_b STATIC)
target_sources(library_b
    PUBLIC
        FILE_SET HEADERS
            BASE_DIRS include
            FILES include/library_b/library_b.hpp
    PRIVATE
        src/library_b.cpp
)
target_include_directories(library_b PUBLIC include)
target_link_libraries(library_b PUBLIC library_c)
target_compile_features(library_b PUBLIC cxx_std_23)
