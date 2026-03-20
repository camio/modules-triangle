module;

#ifndef ABC_HAS_IMPORT_STD
#include <string>
#else
import std;
#endif

#include <library_c/library_c.hpp>
#include <library_b/library_b.hpp>

export module library_a;

export namespace library_a {
    std::string describe();
}
