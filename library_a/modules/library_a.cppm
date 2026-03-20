module;

#ifndef ABC_HAS_IMPORT_STD
#include <string>
#else
import std;
#endif

#include <library_c/library_c.hpp>  // NOLINT(misc-include-cleaner)
#include <library_b/library_b.hpp>  // NOLINT(misc-include-cleaner)

export module library_a;

export namespace library_a {
    std::string describe();
}
