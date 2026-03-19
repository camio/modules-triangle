module;

#include <string>

export module library_c;

#define LIBRARY_C_INCLUDED_FROM_INTERFACE_UNIT
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Winclude-angled-in-module-purview"
#include <library_c/library_c.hpp>
#pragma clang diagnostic pop
