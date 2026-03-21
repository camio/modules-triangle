#! /bin/sh
#
# from https://gcc.gnu.org/bugzilla/show_bug.cgi?id=99000
# The following header unit import causes the "declaration conflicts with import" error:
#
set -e

mkdir -p build && cd build && rm -f * || echo ignored

cat <<EOF >hello.hxx
#pragma once

#include <string_view>

namespace hello
{
  void
  say_hello (const std::string_view& name);
}
EOF

cat <<EOF >hello.cxx
import "hello.hxx";

#include <iostream>

namespace hello
{
  void
  say_hello (const std::string_view& name)
  {
    std::cout << "Hello, " << name << '\n';
  }
}

int main() { hello::say_hello("from g++"); }
EOF

# from https://clang.llvm.org/docs/StandardCPlusPlusModules.html#how-to-produce-bmis
cat <<EOF >greeting.hpp
#pragma once

#include <string_view>
#include <print>

inline void greeting(const std::string_view& name) {
  std::println("Hallo, {}!", name);
}
EOF

cat <<EOF >use.cpp
import "greeting.hpp";

int main() { greeting("from clang++"); }
EOF

cat <<EOF >main.cpp
import <print>;
int main() {
  std::println("Hello World from libc++!");
}
EOF

set -x

g++ --version
g++ -std=c++23 -fmodules-ts -fmodule-header -x c++-header hello.hxx
time g++ -std=c++23 -fmodules-ts -x c++ hello.cxx -o hello
./hello
ls -lrta

# see https://clang.llvm.org/docs/StandardCPlusPlusModules.html#compiling-a-header-unit-to-an-object-file
# For headers which do not have a file extension, -xc++-header (or -xc++-system-header, -xc++-user-header)
# must be used to specify the file as a header.
clang++ --version
clang++ -std=c++23 -fmodule-header greeting.hpp -o greeting.pcm
time clang++ -std=c++23 -fmodule-file=greeting.pcm use.cpp -o use-include
./use-include

# see https://clang.llvm.org/docs/StandardCPlusPlusModules.html#include-translation
# Clang can find the BMI for <print> and so it tries to replace the #include <print>
# with import <print>; automatically.
clang++ -std=c++23 -fmodule-header=system -xc++-header print -o print.pcm
clang++ -std=c++23 -fmodule-header=system -xc++-header string_view -o string_view.pcm
time clang++ -std=c++23 -fmodule-file=string_view.pcm -fmodule-file=print.pcm \
    -fmodule-file=greeting.pcm use.cpp -o use-import
./use-import
ls -lrta

# https://clang.llvm.org/docs/StandardCPlusPlusModules.html#differences-between-clang-modules-and-header-units
# This example is simplified when using libc++:
time clang++ -std=c++23 main.cpp -fimplicit-modules -fimplicit-module-maps -o main
./main
ls -lrta
