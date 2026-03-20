#pragma once

#ifndef LIBRARY_C_INCLUDED_FROM_INTERFACE_UNIT
#include <library_c/config.hpp>
#endif

#if defined(LIBRARY_C_ENABLE_MODULE_SUPPORT) && !defined(LIBRARY_C_INCLUDED_FROM_INTERFACE_UNIT)

// Module build: module consumer imports the module.
import library_c;

#else

#ifdef LIBRARY_C_INCLUDED_FROM_INTERFACE_UNIT

// Module build: it exports the interface.
#define LIBRARY_C_EXPORT export

#else

// Tradinoal build: it declare the interface.
#define LIBRARY_C_EXPORT
#include <string>
#endif

LIBRARY_C_EXPORT namespace library_c {
    std::string describe();
}

#undef LIBRARY_C_EXPORT

#endif
