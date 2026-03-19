cmake_minimum_required(VERSION 3.30)
project(tests LANGUAGES CXX)

add_executable(tests main.cpp)
target_link_libraries(tests PRIVATE library_a)
target_compile_features(tests PRIVATE cxx_std_23)
