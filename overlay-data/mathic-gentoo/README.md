# Gentoo packages for mathic and mathicgb

This overlay also includes **MPSolve 3.2.3**, **msolve 0.10.1**, and an initial
**CMake-based Macaulay2** package. See [README-mpsolve.md](README-mpsolve.md),
[README-msolve.md](README-msolve.md), and [README-Macaulay2.md](README-Macaulay2.md)
for installation and testing.


Self-contained local overlay containing:

| Package | Release | Purpose |
| --- | --- | --- |
| `dev-libs/memtailor` | 1.4-r1 | Memory allocators; copied from the existing memtailor overlay |
| `dev-libs/mathic` | 1.5-r1 | Data structures for Groebner basis computations |
| `dev-libs/mathicgb` | 1.4-r2 | Groebner basis library and `mgb` command-line program |

Mathic uses release commit `b0440c989597f82f31170fb01446a57fc1c3c7b7`;
mathicgb uses `eae920070f0e9f8b34c08148f4caab7f89195601`. Manifests contain
BLAKE2B and SHA512 checksums of the tagged GitHub archives.

## Installation

Either copy the `dev-libs` package directories into your existing local overlay,
or register this directory in `/etc/portage/repos.conf/mathic-local.conf`:

```ini
[mathic-local]
location = /home/dima/software/mathic-gentoo
masters = gentoo
auto-sync = no
```

Accept `~amd64` for these packages under `/etc/portage/package.accept_keywords/`:

```text
dev-libs/memtailor ~amd64
dev-libs/mathic ~amd64
dev-libs/mathicgb ~amd64
```

Then run as root:

```sh
emerge --ask dev-libs/mathic dev-libs/mathicgb
```

No package has been installed into the live system as part of preparing this
overlay, and no Portage configuration has been changed. The new package metadata
has no assigned maintainer; assign a willing maintainer before upstream submission.

## USE flags and tests

All three packages offer `test`, disabled by default. Add, for example:

```text
dev-libs/memtailor test
dev-libs/mathic test
dev-libs/mathicgb test
```

to `/etc/portage/package.use/`, then run:

```sh
FEATURES="${FEATURES} test" emerge --ask --oneshot dev-libs/mathic dev-libs/mathicgb
```

The USE flag enables the GoogleTest dependency and test compilation; the Portage
`test` feature runs CTest through the inherited `cmake_src_test` phase. An explicit
`src_test()` wrapper is unnecessary. Tests require system GoogleTest and fail
configuration if it is absent, instead of downloading it during the build.

Mathicgb also offers `tbb`, enabled by default, for parallel computation with
oneTBB. Set `dev-libs/mathicgb -tbb` to build without it. The public compile flag
`MATHICGB_NO_TBB` is then exported to consumers. `mgb` is built in either case.
Mathic's optional benchmark simulators are disabled.

## CMake and ABI support

Both new ebuilds use EAPI 8 and the `cmake` eclass, with CMake 3.18 or newer. Local patches correct library,
header and man-page installation paths, set Autotools-compatible SONAMEs
(`libmathic.so.0` and `libmathicgb.so.0`), and install CMake and pkg-config metadata.
Upstream adaptations for current master are proposed in
https://github.com/Macaulay2/mathic/pull/29 and
https://github.com/Macaulay2/mathicgb/pull/84. The `-r1` ebuild patches include the CMake changes from those PRs,
including dependency discovery through CMake configs with a pkg-config fallback.
They are adapted to the tagged releases: mathicgb retains its release source
and test lists, without adding tests that exist only on upstream master.
Upstream CI workflow changes are not needed in the ebuild patches.
Memtailor's patch is from https://github.com/Macaulay2/memtailor/pull/23.

Consumers can use:

```cmake
find_package(mathic 1.5 CONFIG REQUIRED)
target_link_libraries(my_program PRIVATE mathic::mathic)

# For consumers of the Groebner basis library:
find_package(mathicgb 1.4 CONFIG REQUIRED)
target_link_libraries(my_gb_program PRIVATE mathicgb::mathicgb)
```

The targets supply C++17 and transitive dependencies. On amd64 Gentoo the configs
are installed under `/usr/lib64/cmake/{mathic,mathicgb}` and pkg-config metadata
under `/usr/lib64/pkgconfig`. Nonstandard CMake prefixes can be supplied as a
quoted semicolon-separated `-DCMAKE_PREFIX_PATH='/prefix/one;/prefix/two'` list;
the Unix environment variable of the same name uses colons.

The installed packages export their own `MATHIC_DEBUG` / `MATHICGB_DEBUG` settings
and inherit dependency ABI flags through the dependency targets or pkg-config
`Requires`. Building one library in Debug does not arbitrarily enable a different
ABI for its already installed dependencies. Gentoo's normal RelWithDebInfo build
has debug symbols but does not enable these ABI-changing macros.

This prepares external libraries for subsequent M2 integration; it does not
change M2's current selection of bundled mathic/mathicgb.

## Validation

Build/test logs and staging trees are under
`/home/dima/tmp/mathic-packaging/`. Validation uses low CPU priority, idle I/O
priority, and at most two compilation jobs. Portage phases are run as the normal
user with sandbox/user switching disabled and temporary output directories;
this is not a check of Portage sandbox enforcement or a root installation.

To run overlay QA:

```sh
pkgcheck scan /home/dima/software/mathic-gentoo
```

Completed checks:

* Actual Portage unpack, patch, configure, compile, test, and staged-install phases
  passed for both packages with `USE=test`; all 14 mathic and 237 mathicgb tests
  passed. Mathicgb used TBB in this run.
* Actual ebuild build/install phases also passed with `USE=-test`, and with
  `USE=-tbb` for mathicgb.
* Consumers of the staged installations compiled and ran through both CMake and
  pkg-config. A CMake consumer requesting C++11 inherited C++17 from the target.
* The no-TBB CMake consumer inherited `MATHICGB_NO_TBB`; its library has no TBB
  dependency. `mgb version` reported 1.4, and the man page was staged in `man1`.
* `pkgcheck scan` reported no findings.

The updated `-r1` patches passed all Portage phases with tests enabled
(14 mathic and 237 mathicgb tests) and staged consumer checks through CMake,
forced pkg-config dependency discovery, and pkg-config directly. Logs:
`ebuild-mathic-r1.log`, `ebuild-mathicgb-r1.log`, and `consumers-r1.log`.
The ebuild staging check reports mathic as absent from the live system;
consumer validation supplies the staged dependency instead. Original validation logs: `ebuild-mathic.log`,
`ebuild-mathicgb.log`, and the corresponding
`ebuild-*-no-test.log` files in the validation directory above.

Debug shared libraries were also installed into a temporary prefix. Release
consumers compiled and ran through CMake and pkg-config while inheriting
`MATHIC_DEBUG`, `MATHICGB_DEBUG`, and the no-TBB setting. The system memtailor's
Release ABI remained unchanged. See `debug-build.log` and the consumer fixtures
under the validation directory.

Mathicgb `1.4-r2` corrects the upstream documentation installation to use
`CMAKE_INSTALL_DOCDIR`, which the Gentoo cmake eclass sets to
`/usr/share/doc/${PF}`. It no longer installs files under `/usr/licenses`.
