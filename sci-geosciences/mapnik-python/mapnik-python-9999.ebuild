# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

PYTHON_COMPAT=( python{2_7,3_4,3_5} )

inherit distutils-r1 git-r3

DESCRIPTION="Python bindings for mapnik."
HOMEPAGE="https://github.com/mapnik/python-mapnik"
EGIT_REPO_URI="https://github.com/mapnik/python-mapnik.git"

LICENSE="LGPL-2.1"
SLOT="0/9999"
KEYWORDS=""

IUSE="cairo"
REQUIRED_USE="$PYTHON_REQUIRED_USE"

RDEPEND="
    dev-libs/boost:=[python,$PYTHON_USEDEP]
    sci-geosciences/mapnik
    cairo? (
        dev-python/pycairo
        sci-geosciences/mapnik[cairo]
    )
    $PYTHON_DEPS"
DEPEND="$RDEPEND"

PATCHES=(
    "$FILESDIR/flags.patch"
    "$FILESDIR/paths.patch"
)

src_prepare() {
    default
    if use cairo; then
        export PYCAIRO=true
    fi
}

python_compile() {
    PYTHON_POSTFIX=$(echo "$EPYTHON" | sed "s/python/python-/")
    export BOOST_PYTHON_LIB="boost_$PYTHON_POSTFIX"
    distutils-r1_python_compile
}

python_install() {
    distutils-r1_python_install
}
