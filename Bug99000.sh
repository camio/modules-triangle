#! /bin/sh

# The following header unit import causes the "declaration conflicts with import" error:

set -e

mkdir -p build && cd build

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
  say_hello (const std::string_view& n)
  {
    std::cout << "Hello, " << n << '!' << std::endl;
  }
}
EOF

set -x

g++ --version
g++ -std=c++20 -fmodules-ts -fmodule-header -x c++-header hello.hxx
g++ -std=c++20 -fmodules-ts -x c++ -c hello.cxx
ls -lrta
