# Copyright 1999-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit flag-o-matic

DESCRIPTION="GNU Common Lisp"
HOMEPAGE="https://www.gnu.org/software/gcl/gcl.html"

if [[ ${PV} =~ _pre ]]; then
	MY_PV="$(ver_rs 1-3 _)"
	MY_PV="$(ver_rs 3-4 '' "${MY_PV}")"

	SRC_URI="http://git.savannah.gnu.org/cgit/gcl.git/snapshot/gcl-Version_${MY_PV}.tar.gz"
	S="${WORKDIR}/gcl-Version_${MY_PV}/gcl"
else
	SRC_URI="mirror://gnu/${PN}/${P}.tar.gz"
fi

LICENSE="LGPL-2+ GPL-2+"
SLOT="0"
KEYWORDS="~amd64 ~arm ~ppc ~ppc64 ~riscv ~x86"
IUSE="athena doc +readline tk X"
RESTRICT="strip" # bug #205803

RDEPEND="
	dev-libs/gmp:=
	readline? ( sys-libs/readline:= )
	athena? ( x11-libs/libXaw )
	tk? ( dev-lang/tk:= )
	X? (
		x11-libs/libXt
		x11-libs/libXext
		x11-libs/libXmu
		x11-libs/libXaw
	)
"
DEPEND="${RDEPEND}"
BDEPEND="
	app-text/texi2html
	virtual/latex-base
	virtual/texi2dvi
"

PATCHES=(
	"${FILESDIR}"/${P}-errata.patch
)

src_configure() {
	filter-lto # bug #931082
	strip-flags
	# Unrelocated non-local symbol: _GLOBAL_OFFSET_TABLE_
	filter-flags -fstack-protector -fstack-protector-all
	append-flags -U_FORTIFY_SOURCE -fno-stack-clash-protection
	append-flags -fno-stack-protector
	append-flags -fno-PIE -no-pie
	append-flags -mdirect-extern-access
	append-flags -Wl,-z,nopack-relative-relocs
	append-flags -O2

	local myconf=(
		--disable-xdr
		$(use_enable readline)
		$(use_enable athena xgcl)
		$(use_with X x)
		$(use_enable tk tcltk)
		$(usev tk --enable-tclconfig=/usr/lib)
		$(usev tk --enable-tkconfig=/usr/lib)
	)

	CONFIG_SHELL="${BROOT}"/bin/bash econf "${myconf[@]}"
}

src_compile() {
	# Insane memory use
	# Saw 20GB per thread
	emake -j1
}

src_test() {
	local make_ansi_tests_clean="rm -f test.out *.fasl *.o *.so *~ *.fn *.x86f *.fasl *.ufsl"

	( make clean && make test-unixport ) || die "make ansi-tests failed!"

	cat "${FILESDIR}/bootstrap-gcl" | ../unixport/saved_ansi_gcl

	cat "${FILESDIR}/bootstrap-gcl" |sed s/bootstrapped_ansi_gcl/bootstrapped_r_ansi_gcl/g \
		| ./bootstrapped_ansi_gcl

	( ${make_ansi_tests_clean} && echo "(load \"gclload.lsp\")" \
		| ./bootstrapped_r_ansi_gcl || die "Phase 2, bootstraped compiler failed in tests" )
}

src_install() {
	emake DESTDIR="${D}" install
	dodoc readme readme.gmp readme.xgcl ChangeLog doc/*

	pushd "${D}"/usr/share/doc > /dev/null
	rm dwdoc.tex || die "rm dwdoc.tex.bz2 failed"
	if use doc; then
		mv *.pdf gcl gcl-si gcl-tk dwdoc ${PF} || die "mv * ${PF} failed"
	else
		rm -rf *.pdf gcl gcl-si gcl-tk dwdoc
	fi
	popd > /dev/null
}
