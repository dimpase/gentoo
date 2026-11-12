# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="Groebner basis computation library and command-line program"
HOMEPAGE="https://github.com/Macaulay2/mathicgb"
SRC_URI="https://github.com/Macaulay2/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0/0"
KEYWORDS="~amd64"
IUSE="test +tbb"
RESTRICT="!test? ( test )"

RDEPEND=">=dev-libs/memtailor-1.4-r1:=
	>=dev-libs/mathic-1.5:=
	tbb? ( dev-cpp/tbb:= )"
DEPEND="${RDEPEND}
	test? ( >=dev-cpp/gtest-1.10.0 )"

PATCHES=( "${FILESDIR}/${P}-cmake-package.patch" )
DOCS=( README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_TESTING=$(usex test)
		-Denable_mgb=ON
		-Dwith_tbb=$(usex tbb)
	)
	# Require the packaged GoogleTest rather than downloading during the build.
	use test && mycmakeargs+=( -DCMAKE_REQUIRE_FIND_PACKAGE_GTest=ON )
	cmake_src_configure
}
