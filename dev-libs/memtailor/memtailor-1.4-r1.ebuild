# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit cmake

DESCRIPTION="C++ library of special purpose memory allocators"
HOMEPAGE="https://github.com/Macaulay2/memtailor"
SRC_URI="https://github.com/Macaulay2/${PN}/archive/refs/tags/v${PV}.tar.gz -> ${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

DEPEND="test? ( >=dev-cpp/gtest-1.10.0 )"

PATCHES=( "${FILESDIR}/${P}-cmake-package.patch" )
DOCS=( README.md )

src_configure() {
	local mycmakeargs=(
		-DBUILD_SHARED_LIBS=ON
		-DBUILD_TESTING=$(usex test)
	)
	# Fail rather than download GoogleTest if the test dependency is missing.
	use test && mycmakeargs+=( -DCMAKE_REQUIRE_FIND_PACKAGE_GTest=ON )
	cmake_src_configure
}
