module;

#include <string>
#include <library_c/library_c.hpp>
#include <library_b/library_b.hpp>

module library_a;

namespace library_a {
std::string describe() { return "library_a (using " + library_c::describe() + " and " + library_b::describe() + ")"; }
} // namespace library_a
