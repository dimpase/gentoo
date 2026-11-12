# msolve for Gentoo

This overlay includes `sci-mathematics/msolve-0.10.1`, using the upstream release:
https://github.com/algebraic-solving/msolve/releases/tag/v0.10.1

It provides the `msolve` command, `libmsolve.so.3`, `libneogb.so.3`, development
headers under `/usr/include/msolve`, and `msolve.pc` for pkg-config. It depends
on Gentoo's GMP, MPFR, and FLINT (3.0 or newer). M2's existing
`FindMSolve.cmake` discovers the installed library and headers; a separate
CMake package config is not needed for this integration.

## Installation

Copy `sci-mathematics/msolve` into your local overlay, or register this overlay
as described in `README.md`. Accept the keyword in package.accept_keywords:

```text
sci-mathematics/msolve ~amd64
```

Then run:

```sh
emerge --ask sci-mathematics/msolve
```

`openmp` is enabled by default for parallel computations. It can be disabled
with `sci-mathematics/msolve -openmp` in package.use.

## Tests

Add to package.use:

```text
sci-mathematics/msolve test
```

Then run:

```sh
FEATURES="${FEATURES} test" emerge --ask --oneshot sci-mathematics/msolve
```

The explicit `src_test()` runs the upstream `emake check` suite, including
library tests and solver input/output regression tests. No separate test
framework is required. Tests are built only by `make check`.

## Compiler flags and installation

A packaging patch selects AVX2 and AVX512F implementations using the compiler's
predefined target macros instead of automatically detecting the build machine's
CPU and appending instruction-set flags. Set the intended target through your
normal Gentoo CFLAGS (for example `-march=...`). The scalar implementation is
used when neither extension is enabled. This also avoids host CPU detection
when cross-compiling.

The ebuild uses upstream Autotools, respects compiler/linker flags and Gentoo's
library directory, disables static libraries, and removes libtool archives.
The subslot tracks shared-library ABI 3. No live-system installation or Portage
configuration changes are made while preparing the package.

## Validation

Both builds passed the actual Portage unpack, prepare, configure, compile,
test, and staged-install phases on amd64 Gentoo with GCC 16.2.0 and FLINT 3.5.0:

* OpenMP enabled, using the machine's normal CFLAGS: **64/64 tests passed**.
* OpenMP disabled, `CFLAGS='-O2 -pipe -march=x86-64'`: **64/64 tests passed**.
  The configuration has neither AVX2 nor AVX512F enabled, and the installed
  libraries have no direct OpenMP runtime dependency.
* M2's actual `FindMSolve.cmake` found the staged library and headers. CMake and
  pkg-config consumers compiled, linked, and ran against the staged libraries.
* The installed CLI computed the expected reduced Groebner basis for
  `x-1, y-2` over the rationals.
* Shared-library SONAMEs are `libmsolve.so.3` and `libneogb.so.3`; no RPATH,
  static archives, or libtool archives remain in the installed tree.
* `pkgcheck scan` reported no findings.

Validation used eight build jobs at low CPU and idle I/O priority. Logs,
consumer sources, and staging trees are under `/home/dima/tmp/msolve-packaging/`:
`ebuild-test.log` (successful build/tests, followed by an initial documentation
installation error), `ebuild-install.log` (corrected successful install),
`ebuild-scalar.log` (complete second build), and `consumer-validation.log`.
Portage was run as the normal user with sandbox/user switching disabled; this
validates staged builds but not root installation or Portage sandbox enforcement.
