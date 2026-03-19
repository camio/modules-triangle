# modules-triangle

A CMake project demonstrating C++23 modules interop across three libraries with a triangular dependency graph. The key challenge: a library (C) supports both module and non-module consumers, and the project exercises both consumption paths simultaneously.

## Dependency Graph

```
tests
  └── library_a (module)
        ├── library_b (traditional headers)
        │     └── library_c (module or headers)
        └── library_c (module or headers)
```

- **library_a** is always a C++ module. It imports library_c via the compatibility header and uses library_b's header API.
- **library_b** is a traditional header/source library. It consumes library_c through library_c's compatibility header.
- **library_c** can be built with or without module support (`-DLIBRARY_C_MODULES=ON|OFF`). It provides a compatibility header that either triggers `import library_c;` (when modules are enabled) or provides declarations directly (when modules are disabled).

## The Compatibility Header Pattern

The core technique lives in `library_c/include/library_c/library_c.hpp`. This single header serves three roles depending on context:

1. **Included from the module interface unit** (`LIBRARY_C_INCLUDED_FROM_INTERFACE_UNIT` defined): Provides `export`-annotated declarations that become part of the module interface.
2. **Included by a non-module consumer when modules are enabled** (`LIBRARY_C_ENABLE_MODULE_SUPPORT` defined): Emits `import library_c;` so consumers transparently get the module.
3. **Included when modules are disabled**: Provides plain declarations directly.

A generated `config.hpp` (via `configure_file`) communicates the `LIBRARY_C_ENABLE_MODULE_SUPPORT` flag to consumers.

### Imports in the Global Module Fragment

The compatibility header can trigger an `import` when `#include`d from within the global module fragment of a `.cppm` file (e.g., in `library_a.cppm`). At first glance this seems problematic — the standard prohibits directly writing `import` in the global module fragment. However, the interaction of several rules permits this indirectly.

#### The Rules

**`[cpp.pre] p5`** prohibits `pp-import` directives in the `pp-global-module-fragment` "at the start of phase 4 of translation." Phase 4 is where preprocessing occurs — `#include` directives are resolved, macros are expanded, and conditional compilation is evaluated. The "at the start of" qualifier means the check applies to the literal source text before any of this preprocessing takes place. A developer therefore cannot directly write `import` in the global module fragment.

**`[cpp.include] p10`** permits an implementation to rewrite a `#include` directive naming an importable header into an equivalent `import` directive. This rewriting occurs during phase 4, not at its start.

**`[cpp.import] p2`** makes the program ill-formed if a `pp-import` is produced by source file inclusion "while processing the group of a module-file." However, the grammar for `module-file` is:

```
module-file:
    line-directives_opt  pp-global-module-fragment_opt  pp-module  group_opt
    pp-private-module-fragment_opt
```

The `pp-global-module-fragment` contains its own distinct `group` non-terminal. "The group of a module-file" most naturally refers to the `group_opt` directly owned by the `module-file` production — the module body after the module declaration — not the `group` nested inside the `pp-global-module-fragment`.

#### The Consequence

Under this reading, none of the three rules prohibit the following scenario: a `#include` in the global module fragment names an importable header, and the implementation rewrites it to an `import` during phase 4. The `[cpp.pre] p5` check passes because no `pp-import` exists at the start of phase 4. The `[cpp.import] p2` prohibition does not apply because the global module fragment's `group` is not "the group of a module-file."

#### Conclusion

The standard does allow module imports in the global module fragment, but only indirectly — through a `#include` of an importable header that the implementation rewrites to an `import`. A directly-written `import` remains prohibited. However, the wording across these three sections is not coordinated in a way that makes this intent clear, and the precise scope of `[cpp.import] p2`'s "the group of a module-file" would benefit from clarification.

### Shared Implementation

Because C++ requires `module;` to be the first token in a module implementation unit (no `#ifdef` allowed before it), library_c needs two source files for the two build modes. Both include a shared `library_c_impl.hpp` to avoid duplicating function bodies:

- `library_c.cppm.cpp` -- module implementation unit (used when modules are ON)
- `library_c.cpp` -- traditional source (used when modules are OFF)
- `library_c_impl.hpp` -- shared function definitions

## Build Instructions

### Requirements

- **CMake** 3.30+ (4.3 recommended for experimental `import std` support)
- **Ninja** build system
- **Homebrew Clang** 21+ (see [Compiler Notes](#compiler-notes) for why other compilers don't work)

### Modules Enabled (default)

```bash
cmake -B build -G Ninja \
  -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm/bin/clang++ \
  -DCMAKE_CXX_FLAGS="--sysroot=$(xcrun --show-sdk-path)"
cmake --build build
./build/tests/tests
```

Expected output:

```
library_a (using library_c and library_b (using library_c))
```

### Modules Disabled for library_c

```bash
cmake -B build -G Ninja \
  -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm/bin/clang++ \
  -DCMAKE_CXX_FLAGS="--sysroot=$(xcrun --show-sdk-path)" \
  -DLIBRARY_C_MODULES=OFF
cmake --build build
./build/tests/tests
```

### Experimental `import std` Support

The project enables CMake's experimental `import std;` support. If CMake can locate your toolchain's `modules.json`, it will build `std` as a module automatically. With Homebrew Clang, you may need to point CMake to the metadata file:

```bash
cmake -B build -G Ninja \
  -DCMAKE_CXX_COMPILER=/opt/homebrew/opt/llvm/bin/clang++ \
  -DCMAKE_CXX_FLAGS="--sysroot=$(xcrun --show-sdk-path)" \
  -DCMAKE_CXX_STDLIB_MODULES_JSON=/opt/homebrew/opt/llvm/lib/c++/libc++.modules.json
```

Note: The `CMAKE_EXPERIMENTAL_CXX_IMPORT_STD` UUID in the top-level `CMakeLists.txt` is tied to a specific CMake version. If you upgrade CMake, you may need to update the UUID from the [CMake experimental.rst](https://github.com/Kitware/CMake/blob/master/Help/dev/experimental.rst) file.

## Compiler Notes

### AppleClang (does not work)

AppleClang (the default `/usr/bin/clang++` on macOS) does not support C++ module dependency scanning, which CMake's `CXX_MODULES` file set requires. CMake will error at configure time:

> The target has C++ sources that may use modules, but the compiler does not provide a way to discover the import graph dependencies.

### GCC (does not work -- any platform)

GCC cannot build this project due to **[GCC Bug 99000](https://gcc.gnu.org/bugzilla/show_bug.cgi?id=99000)** (open since 2021). GCC cannot deduplicate standard library symbols when a textual `#include` follows an `import` that already brought those symbols in via its global module fragment. The C++ standard requires this deduplication, but GCC only implements it in the opposite direction (include-then-import). This is the exact pattern the compatibility header creates: `import library_c;` brings in `<string>` symbols, then a subsequent `#include <string>` causes redefinition errors.

We tested the following GCC versions, all with the same result:

| Version | Platform | Result |
|---------|----------|--------|
| GCC 15.2 (Homebrew) | macOS (ARM64) | Bug 99000 + macOS SDK conflicts with `module std` |
| GCC 15.2 (`gcc:latest` Docker) | Linux (ARM64) | Bug 99000 (`module std` builds fine) |
| GCC 16.0.1 20260315 (`sourcemation/gcc-16` Docker) | Linux (x86_64) | Bug 99000 (still unfixed in trunk) |

On macOS specifically, GCC has an additional issue: the macOS SDK headers conflict with libstdc++ headers when building `module std`, so even `import std` fails. On Linux this is not a problem -- `module std` builds fine, but bug 99000 still prevents the compatibility header pattern from working.

GCC support will require a fix for bug 99000. As of March 2026, the bug remains open with no fix in trunk despite some related improvements.

### Homebrew Clang 21+ (works)

Homebrew's LLVM/Clang (`/opt/homebrew/opt/llvm/bin/clang++`) fully supports C++ module dependency scanning and correctly deduplicates standard library symbols across module/header boundaries. The `--sysroot` flag is needed to point it at the macOS SDK for system headers.

## Project Structure

```
modules-triangle/
├── CMakeLists.txt                              # Top-level, enables import std
├── library_a/
│   ├── CMakeLists.txt                          # Module library
│   ├── modules/library_a.cppm                  # Module interface
│   └── src/library_a.cpp                       # Module implementation
├── library_b/
│   ├── CMakeLists.txt                          # Traditional static library
│   ├── include/library_b/library_b.hpp         # Public header
│   └── src/library_b.cpp                       # Implementation
├── library_c/
│   ├── CMakeLists.txt                          # Module or traditional (configurable)
│   ├── modules/library_c.cppm                  # Module interface
│   ├── include/library_c/
│   │   ├── library_c.hpp                       # Compatibility header
│   │   └── config.hpp.in                       # Generated config template
│   └── src/
│       ├── library_c.cpp                       # Traditional implementation
│       ├── library_c.cppm.cpp                  # Module implementation
│       └── library_c_impl.hpp                  # Shared function definitions
└── tests/
    ├── CMakeLists.txt
    └── main.cpp                                # Imports library_a, runs describe()
```
