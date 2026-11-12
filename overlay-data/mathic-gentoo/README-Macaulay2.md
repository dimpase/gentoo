# Macaulay2: CMake-based Gentoo package

The initial ebuild is `sci-mathematics/Macaulay2-1.26.06_p20260916`, a pinned
snapshot of upstream development at
`a2d1596ed8950a4e87c11b8ea895de8798c1e63f` (2026-09-16), plus the external
memtailor/mathic/mathicgb integration from PR #4728, commit `606be2cda5`.
It is not the unmodified 1.26.06 release. The Emacs support sources are pinned
to the snapshot's submodule revision and fetched through SRC_URI.

## Installation

Use this overlay as described in README.md, including its memtailor, mathic,
mathicgb, MPSolve, and msolve packages. Accept the keyword:

```text
sci-mathematics/Macaulay2 ~amd64
```

Then run:

```sh
emerge --ask sci-mathematics/Macaulay2
```

The build uses Ninja through Gentoo's cmake eclass. It uses system libraries,
including Factory from Singular, with strict SYSTEM selection for the three
mathic libraries. Configuration fails if a required library cannot be found.
The upstream external-project download/build machinery is disabled, and npm
is not run. Documentation assets already in the source snapshot are retained.
Paths under `/usr/local` are excluded from CMake dependency discovery.
Factory finite-field tables are read directly from Singular's system data
directory instead of being bundled. Compiler caching is left to Portage
rather than enabled automatically by upstream CMake.

## Features and tests

* `python` (enabled by default) provides the Python interface and uses Gentoo's
  `PYTHON_SINGLE_TARGET` selection.
* `doc` (disabled by default) runs `install-packages` to generate the distributed
  packages' HTML/Info documentation. This can take substantially longer than
  compiling the engine. It does not request the separate internal developer
  documentation controlled upstream by BUILD_DOCS.
* `test` enables the M2 engine's C++ unit tests. Run them with
  `FEATURES="${FEATURES} test" emerge --ask --oneshot sci-mathematics/Macaulay2`.
  An additional smoke test checks startup, Groebner bases, factorization, and
  numeric roots. Tests of external libraries belong to their own packages. The full M2 package
  test suite, which requires additional external software, is not run here.

The default build installs the engine, interpreter, Core, distributed M2 package
sources and auxiliary files, man page, and Emacs support. Emacs itself is not
required to generate these support files. Generated package documentation
requires `USE=doc`.

msolve is a dependency. Other optional package interfaces need their own
external programs, such as 4ti2, Gfan, TOPCOM, CSDP, or cohomCalg; these are not
silently built or downloaded. cohomCalg still needs a Gentoo ebuild in this
overlay. Maple is proprietary and optional.

Do not leave an older `/usr/local/bin/M2` ahead of `/usr/bin/M2` in PATH when
trying the installed Gentoo package. Validation and staging do not modify the
live installation or Portage configuration.

## Local validation

Built with eight jobs at low CPU and I/O priority, using `USE="test python -doc"`.
All 275 C++ unit tests passed, as did the M2 smoke test. The staged installation
was also run directly: it loaded its own Core and package sources, used system
Factory finite-field tables and system memtailor/mathic/mathicgb/MPSolve
libraries, and had no unresolved libraries or RPATH pointing into the build tree.
The packaging patch includes a missing return in a C++ test helper found during
this validation. The build still emits upstream unused-variable and Python
feature-macro warnings; QA messages repeated from earlier attempts in Portage's
accumulated log are not new compiler diagnostics.

This was an unprivileged ebuild build/test/install into a staging directory,
without Portage sandbox enforcement or a merge into the live system.
`USE=doc` and the full distributed-package test suite have not been validated.

Gentoo's nauty 2.9.3 is sufficient: this source snapshot requests at least 2.7.0
and uses 2.9.3 for its bundled fallback. Nauty is an optional external program,
not a reason to add another dependency ebuild.
