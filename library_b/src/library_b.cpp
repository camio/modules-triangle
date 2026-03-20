#include <library_b/library_b.hpp>
#include <library_c/library_c.hpp>
#include <string>

namespace library_b {
    std::string describe() {
        return "library_b (using " + library_c::describe() + ")";
    }
}
