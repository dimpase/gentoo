# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

PYTHON_COMPAT=( python3_{11..15} )
inherit cmake python-single-r1 toolchain-funcs

M2_COMMIT=a2d1596ed8950a4e87c11b8ea895de8798c1e63f
EMACS_COMMIT=ae882ab04da19f62c62462ef9604251a0b30a9f5
DESCRIPTION="Computer algebra system for algebraic geometry and commutative algebra"
HOMEPAGE="https://macaulay2.com/"
SRC_URI="https://github.com/Macaulay2/M2/archive/${M2_COMMIT}.tar.gz -> ${PN}-${M2_COMMIT}.tar.gz
	https://github.com/Macaulay2/M2-emacs/archive/${EMACS_COMMIT}.tar.gz -> M2-emacs-${EMACS_COMMIT}.tar.gz"
S="${WORKDIR}/M2-${M2_COMMIT}"

LICENSE="GPL-2+ GPL-3+ MIT"
SLOT="0"
KEYWORDS="~amd64"
IUSE="doc +python test"
REQUIRED_USE="python? ( ${PYTHON_REQUIRED_USE} )"
RESTRICT="!test? ( test )"

RDEPEND="dev-cpp/tbb:=
	dev-libs/boost:=
	dev-libs/boehm-gc:=[threads]
	dev-libs/gmp:0=
	dev-libs/jansson:=
	dev-libs/libffi:=
	dev-libs/libxml2:2=
	dev-libs/mpfr:0=
	dev-libs/ntl:=
	>=dev-libs/memtailor-1.4-r1:=
	>=dev-libs/mathic-1.5-r1:=
	>=dev-libs/mathicgb-1.4-r2:=[tbb]
	sci-libs/fflas-ffpack
	sci-libs/givaro:=
	sci-libs/mpfi:=
	>=sci-libs/mpsolve-3.2.3:=
	>=sci-mathematics/flint-3.0:=
	sci-mathematics/frobby:=
	sci-mathematics/glpk:=
	sci-mathematics/normaliz:=
	>=sci-mathematics/msolve-0.10.1:=
	>=sci-mathematics/singular-4.4.0:=
	sys-libs/gdbm:=
	sys-libs/readline:=
	virtual/lapack
	python? ( ${PYTHON_DEPS} )"
DEPEND="${RDEPEND}
	>=dev-cpp/eigen-3.4.0:3
	test? ( >=dev-cpp/gtest-1.16 )"
BDEPEND=">=dev-build/cmake-3.30
	sys-devel/bison
	sys-apps/which
	sys-apps/texinfo
	virtual/pkgconfig"

PATCHES=(
	"${FILESDIR}/${PN}-external-mathic.patch"
	"${FILESDIR}/${PN}-gentoo-build.patch"
)
CMAKE_USE_DIR="${S}/M2"
DOCS=( README.md )

pkg_setup() {
	if use python; then
		python-single-r1_pkg_setup
	fi
}

src_prepare() {
	cp -a "${WORKDIR}/M2-emacs-${EMACS_COMMIT}/." \
		"${S}/M2/Macaulay2/editors/emacs/" || die
	cp "${FILESDIR}/gentoo-system-libraries.cmake" "${S}/M2/cmake/" || die
	cmake_src_prepare
}

src_configure() {
	tc-check-openmp
	local mycmakeargs=(
		-DGIT_SUBMODULE=OFF
		-DCCACHE=OFF
		-DCMAKE_SKIP_INSTALL_ALL_DEPENDENCY=ON
		-DBUILD_NATIVE=OFF
		-DBUILD_DOCS=OFF
		-DBUILD_TESTING=$(usex test)
		-DCMAKE_INSTALL_DOCDIR="share/doc/${PF}"
		-DSTATIC_BOOST=OFF
		-DGCOV=OFF
		-DWITH_PYTHON=$(usex python)
		-DMEMTAILOR_PROVIDER=SYSTEM
		-DMATHIC_PROVIDER=SYSTEM
		-DMATHICGB_PROVIDER=SYSTEM
		-DCMAKE_IGNORE_PREFIX_PATH=/usr/local
		-DCMAKE_IGNORE_PATH="${EPREFIX}/usr/local/bin;${EPREFIX}/usr/local/sbin"
		-DCMAKE_SKIP_INSTALL_RPATH=ON
	)
	if use python; then
		mycmakeargs+=(
			-DPython3_INCLUDE_DIR="$(python_get_includedir)"
			-DPython3_LIBRARY="$(python_get_library_path)"
		)
	fi
	cmake_src_configure
}

src_compile() {
	cmake_build M2-core M2-emacs
	if use doc; then
		cmake_build install-packages
	fi
	if use test; then
		cmake_build M2-unit-tests
	fi
}

src_test() {
	# Core tests; optional external programs are not required for these tests.
	cmake_src_test -R '^unit-tests:'
	"${BUILD_DIR}/M2" --script "${FILESDIR}/gentoo-smoke.m2" || die
}

src_install() {
	cmake_src_install
	newdoc M2/BUILD/README.md README-CMake.md
	gunzip "${ED}/usr/share/man/man1/M2.1.gz" || die
}
