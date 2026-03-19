#include <library_b/library_b.hpp>

namespace library_b {
    std::string describe() {
        return "library_b (using " + library_c::describe() + ")";
    }
}
