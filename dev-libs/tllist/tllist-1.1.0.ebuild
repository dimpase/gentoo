# Copyright 2020-2025 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=8

inherit meson

DESCRIPTION="Header-only implementation of a typed linked list in C"
HOMEPAGE="https://codeberg.org/dnkl/tllist"
SRC_URI="https://codeberg.org/dnkl/tllist/archive/${PV}.tar.gz -> ${P}.tar.gz"
S="${WORKDIR}/${PN}"

LICENSE="MIT"
SLOT="0"
KEYWORDS="amd64 arm64 ppc64 ~riscv ~x86"

src_install() {
	meson_src_install

	rm -r "${ED}/usr/share/doc/${PN}" || die
}
