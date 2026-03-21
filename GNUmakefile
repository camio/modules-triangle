# Copyright Claus Klein, 2025-2026
# Distributed under the Boost Software License, Version 1.0.
# See accompanying file LICENSE_1_0.txt or copy at http://www.boost.org/LICENSE_1_0.txt

# Standard stuff

.SUFFIXES:

MAKEFLAGS+= --no-builtin-rules  # Disable the built-in implicit rules.
MAKEFLAGS+= --warn-undefined-variables        # Warn when an undefined variable is referenced.

export hostSystemName=$(shell uname)

ifeq (${hostSystemName},Darwin)

  ### NOTE: to test clang++-22:
  ifeq (${CXX},clang++)
    SYSROOT:=$(shell xcrun --show-sdk-path)
    export LLVM_PREFIX:=$(shell brew --prefix llvm)
    export LLVM_DIR:=$(shell realpath ${LLVM_PREFIX})
    export PATH:=${LLVM_DIR}/bin:${PATH}
    export CMAKE_CXX_STDLIB_MODULES_JSON:=${LLVM_DIR}/lib/c++/libc++.modules.json
    export CXXFLAGS:=-stdlib=libc++ --sysroot=$(SYSROOT)
    export LDFLAGS:=-L$(LLVM_DIR)/lib/c++ # XXX -lc++abi
    # XXX export CXX:=clang++
    # XXX export GCOV:="llvm-cov gcov"
  endif

  ### NOTE: to test g++-15:
  ifeq (${CXX},g++-15)
    export GCC_PREFIX:=$(shell brew --prefix gcc)
    export GCC_DIR:=$(shell realpath ${GCC_PREFIX})
    export CMAKE_CXX_STDLIB_MODULES_JSON:=${GCC_DIR}/lib/gcc/current/libstdc++.modules.json
    export CXXFLAGS:=-stdlib=libstdc++
    # XXX export CXX:=g++-15
    # XXX export GCOV:="gcov"
  endif

else ifeq (${hostSystemName},Linux)
	export LLVM_DIR:=/usr/lib/llvm-20
  export PATH:=${LLVM_DIR}/bin:${PATH}
  export CXX:=clang++-20
endif

.PHONY: all install tests check distclean format demo

all: build/compile_commands.json
	ln -sf $< .
	ninja -C build

build/compile_commands.json: CMakeLists.txt GNUmakefile
	cmake --version
	cmake -S . -B build -G Ninja \
  -D CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON} \
  -D CMAKE_CXX_STANDARD=20 -D CMAKE_CXX_EXTENSIONS=YES -D CMAKE_CXX_STANDARD_REQUIRED=YES \
  -D CMAKE_BUILD_TYPE=Release \
  -D LIBRARY_C_MODULES=YES \
  --log-level=VERBOSE --fresh \
  # --trace-expand --trace-source=use-fetch-content.cmake \
  # XXX --debug-find-pkg=GTest

install: build/cmake_install.cmake
	cmake --install build

distclean: # XXX clean
	rm -rf build stagedir compile_commands.json
	find . -name '*~' -delete

format: # distclean
	git ls-files ::*.cmake ::*CMakeLists.txt | xargs gersemi -i --no-warn-about-unknown-commands
	git ls-files ::*.cpp ::*.cppm ::*.hpp | xargs clang-format -i

demo: distclean
	cmake --version
	cmake -S . -B build -G Ninja \
  -D CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON} \
  -D CMAKE_CXX_STANDARD=20 -D CMAKE_CXX_EXTENSIONS=YES -D CMAKE_CXX_STANDARD_REQUIRED=YES \
  -D CMAKE_BUILD_TYPE=Release \
  -D LIBRARY_C_MODULES=NO \
  --log-level=VERBOSE --fresh -Wdev
# -D CMAKE_CXX_COMPILER=${LLVM_DIR}/bin/clang++ \
	ln -sf build/compile_commands.json .
	ninja -C build
	ninja -C build test

check: compile_commands.json
	run-clang-tidy -checks='-*,misc-*' library_*

tests: tests/CMakeLists.txt
	cmake --version
	cmake -S tests -B build/find-tests -G Ninja \
  -D CMAKE_EXPERIMENTAL_CXX_IMPORT_STD="451f2fe2-a8a2-47c3-bc32-94786d8fc91b" \
  -D CMAKE_CXX_STDLIB_MODULES_JSON=${CMAKE_CXX_STDLIB_MODULES_JSON} \
  -D CMAKE_CXX_STANDARD=20 -D CMAKE_CXX_EXTENSIONS=YES -D CMAKE_CXX_STANDARD_REQUIRED=YES \
  -D CMAKE_BUILD_TYPE=Release \
  --fresh # XXX --debug-find-pkg=modules_triangle
	ln -sf build/find-tests/compile_commands.json .
	ninja -C build/find-tests
	ninja -C build/find-tests test
	run-clang-tidy -checks='-*,misc-*' tests

# Anything we don't know how to build will use this rule.
% ::
	ninja -C build $(@)
