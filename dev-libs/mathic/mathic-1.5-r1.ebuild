# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++ data structures for Groebner basis computations"
HOMEPAGE="https://github.com/Macaulay2/mathic"
SRC_URI="https://github.com/Macaulay2/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="LGPL-2+"
SLOT="0/0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND=">=dev-libs/memtailor-1.4-r1:="
DEPEND="${RDEPEND}
	test? ( >=dev-cpp/gtest-1.10.0 )"

PATCHES=( "${FILESDIR}/${P}-cmake-package.patch" )
DOCS=( README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_TESTING=$(usex test)
		-Denable_pqsim=OFF
		-Denable_divsim=OFF
	)
	# Require the packaged GoogleTest rather than downloading during the build.
	use test && mycmakeargs+=( -DCMAKE_REQUIRE_FIND_PACKAGE_GTest=ON )
	cmake_src_configure
}
