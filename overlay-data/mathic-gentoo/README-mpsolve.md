# MPSolve for Gentoo

This overlay includes `sci-libs/mpsolve-3.2.3`, based on the official release:
https://numpi.dm.unipi.it/scientific-computing-libraries/mpsolve/

It installs the `mpsolve` command, `libmps.so.3`, development headers under
`/usr/include/mps`, the manual page, and MIME metadata. GMP with its C++ interface
is the runtime dependency. The GUI, language bindings, examples, graphical
debugger, and optional tcmalloc allocator are disabled. The package uses the
upstream Autotools build; M2's existing `FindMPSolve.cmake` locates its headers
and library without requiring a separate CMake configuration package.

## Installation and tests

Copy `sci-libs/mpsolve` into your local overlay, or use this overlay as described
in `README.md`. Accept the keyword:

```text
sci-libs/mpsolve ~amd64
```

Then run:

```sh
emerge --ask sci-libs/mpsolve
```

To enable the upstream test suite, add this to `/etc/portage/package.use/`:

```text
sci-libs/mpsolve test
```

and run:

```sh
FEATURES="${FEATURES} test" emerge --ask --oneshot sci-libs/mpsolve
```

The `test` USE flag adds `dev-libs/check` and enables test compilation.
The explicit `src_test()` phase runs `emake check`. Without `test`, Check is
not detected or used even if it happens to be installed.

## Packaging adjustments

* Regenerate obsolete yacc output from the release using Bison, as M2's
  bundled-library build already does.
* Correct the installed header version from 3.2.2 to 3.2.3.
* Add an explicit configure option for tests, requiring Check when requested.
* Avoid probing Python when examples and bindings are disabled.
* Disable static libraries and remove libtool archives from the installed tree.
* Refresh MIME metadata through Gentoo's post-install and post-remove hooks.

The ebuild respects Portage compiler flags and library directories. Its subslot
tracks the installed `libmps.so.3` ABI. No live-system installation or Portage
configuration changes are made while preparing this overlay.

## Local validation

Validation completed on amd64 Gentoo with GCC 16.2.0, eight build jobs,
`nice -n 19`, and idle I/O priority:

* Portage unpack, prepare, configure, compile, test, and staged install passed
  with `USE=test`; all 16 upstream test programs passed.
* A separate default `USE=-test` build and staged install passed, with Check
  available in the search path but disabled by configuration.
* M2's actual `FindMPSolve.cmake` detected version 3.2.3 in the staged headers
  and selected the staged shared library. A C++ consumer compiled, linked,
  and verified both roots of `x^2 - 1`; the staged CLI also solved that polynomial.
* The installed library has SONAME `libmps.so.3`, no build-directory RPATH,
  and no dependency on the test framework. No static or libtool archives remain.
* `pkgcheck scan` reported no findings.

Logs and consumer sources are in `/home/dima/tmp/mpsolve-packaging/`, notably
`ebuild-final.log`, `ebuild-no-test.log`, `consumer-final.log`,
`consumer-build-final.log`, and `cli.log`. Builds used the normal user with
Portage sandbox/user switching disabled, and staged installation under the home
directory. This does not test a root installation or Portage sandbox enforcement.
Check 0.15.2 was built in a temporary prefix for validation because it is not
installed on this machine; normal emerge installs the declared test dependency.
