cmake_minimum_required(VERSION 3.30...4.3)

project(tests LANGUAGES CXX)

if(PROJECT_IS_TOP_LEVEL)
    find_package(modules_triangle 0.1.0 EXACT REQUIRED) # TODO(CK): COMPONENTS modules_triangle)

    if(${CMAKE_CXX_STANDARD} IN_LIST CMAKE_CXX_COMPILER_IMPORT_STD)
        set(CMAKE_CXX_MODULE_STD 1)
        message(STATUS "Using `import std;`")
    endif()

    enable_testing()
endif()

add_executable(tests main.cpp)
target_link_libraries(tests PRIVATE abc::library_a)
target_compile_features(tests PRIVATE cxx_std_23)

if(CMAKE_CXX_MODULE_STD)
    message(STATUS "Build tests with target PROPERTY CXX_MODULE_STD ON")
    set_property(TARGET tests PROPERTY CXX_MODULE_STD ON)
endif()

add_test(NAME tests COMMAND tests)
