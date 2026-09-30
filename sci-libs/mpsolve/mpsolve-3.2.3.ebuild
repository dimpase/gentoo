# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools xdg-utils

DESCRIPTION="Multiprecision polynomial root solver and library"
HOMEPAGE="https://numpi.dm.unipi.it/scientific-computing-libraries/mpsolve/"
SRC_URI="https://numpi.dm.unipi.it/wp-content/uploads/2025/08/${P}.tar.bz2"

LICENSE="GPL-3+"
SLOT="0/3"
KEYWORDS="~amd64"
IUSE="test"
RESTRICT="!test? ( test )"

RDEPEND="dev-libs/gmp:0=[cxx]"
DEPEND="${RDEPEND}
	test? ( >=dev-libs/check-0.9.4 )"
BDEPEND="sys-devel/bison
	sys-devel/flex
	virtual/pkgconfig"

PATCHES=( "${FILESDIR}/${P}-configure.patch" )
DOCS=( AUTHORS ChangeLog NEWS README )

src_prepare() {
	default
	# The release ships obsolete yacc output; regenerate it with Bison.
	rm src/libmps/monomial/yacc-parser.{c,h} || die
	eautoreconf
}

src_configure() {
	econf \
		--disable-static \
		--disable-debug \
		--disable-debug-build \
		--disable-examples \
		--disable-ui \
		--disable-qml-ui \
		--disable-graphical-debugger \
		--disable-documentation \
		--disable-tcmalloc \
		$(use_enable test tests)
}

src_test() {
	emake check
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}

pkg_postinst() {
	xdg_mimeinfo_database_update
}

pkg_postrm() {
	xdg_mimeinfo_database_update
}
