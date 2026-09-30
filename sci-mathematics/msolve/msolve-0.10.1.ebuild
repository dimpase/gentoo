# Copyright 2026 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit autotools toolchain-funcs

DESCRIPTION="Library and solver for multivariate polynomial systems"
HOMEPAGE="https://msolve.lip6.fr/ https://github.com/algebraic-solving/msolve"
SRC_URI="https://github.com/algebraic-solving/${PN}/releases/download/v${PV}/${P}.tar.gz"

LICENSE="GPL-2+"
SLOT="0/3"
KEYWORDS="~amd64"
IUSE="+openmp test"
RESTRICT="!test? ( test )"

RDEPEND="dev-libs/gmp:0=
	dev-libs/mpfr:0=
	>=sci-mathematics/flint-3.0:="
DEPEND="${RDEPEND}"

PATCHES=( "${FILESDIR}/${P}-cpu-flags.patch" )
DOCS=( README.md AUTHORS )

src_prepare() {
	default
	eautoreconf
}

src_configure() {
	use openmp && tc-check-openmp
	econf --disable-static $(use_enable openmp)
}

src_test() {
	emake check
}

src_install() {
	default
	find "${ED}" -name '*.la' -delete || die
}
