# Copyright 1999-2016 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Id$

EAPI="6"

inherit eutils scons-utils toolchain-funcs git-r3

DESCRIPTION="A Free Toolkit for developing mapping applications."
HOMEPAGE="https://github.com/mapnik/mapnik"
EGIT_REPO_URI="https://github.com/mapnik/mapnik.git"
EGIT_BRANCH="v3.0.x"

LICENSE="LGPL-2.1"
SLOT="0/9999"
KEYWORDS=""

IUSE="cairo debug doc gdal postgres sqlite"

RDEPEND="
    >=dev-libs/boost-1.48[threads]
    dev-libs/mapbox-variant
    dev-libs/icu:=
    sys-libs/zlib
    media-libs/freetype
    media-libs/harfbuzz
    dev-libs/libxml2
    media-libs/libpng:0=
    media-libs/tiff:0=
    virtual/jpeg:0=
    media-libs/libwebp
    sci-libs/proj
    media-fonts/dejavu
    x11-libs/agg[truetype]
    cairo? (
        x11-libs/cairo
        dev-cpp/cairomm
    )
    postgres? ( >=dev-db/postgresql-8.3:* )
    gdal? ( sci-libs/gdal )
    sqlite? ( dev-db/sqlite:3 )"
DEPEND="$RDEPEND"

PATCHES=(
    "$FILESDIR/configure-only-once.patch"
    "$FILESDIR/dont-run-ldconfig.patch"
    "$FILESDIR/scons.patch"
)

src_prepare() {
    default

    # do not version epidoc data
    sed -i \
        -e 's:-`mapnik-config --version`::g' \
        utils/epydoc_config/build_epydoc.sh || die

    # force user flags, optimization level
    sed -i -e "s:\-O%s:%s:" \
        -i -e "s:env\['OPTIMIZATION'\]:'$CXXFLAGS':" \
        SConstruct || die

    # force lib32/lib64 value into SConstruct - Bug #630948
    # (scons is broken, it's ignoring LIBDIR value)
    sed -i -e "s:^LIBDIR_SCHEMA_DEFAULT='lib'$:LIBDIR_SCHEMA_DEFAULT=\'$(get_libdir)\':" SConstruct || die
}

src_configure() {
    local PLUGINS=shape,csv,raster,geojson
    use gdal && PLUGINS+=,gdal,ogr
    use postgres && PLUGINS+=,postgis
    use sqlite && PLUGINS+=,sqlite

    MYSCONS=(
        "CC=$(tc-getCC)"
        "CXX=$(tc-getCXX)"
        "INPUT_PLUGINS=$PLUGINS"
        "PREFIX=/usr"
        "DESTDIR=$D"
        "XMLPARSER=libxml2"
        "LINKING=shared"
        "RUNTIME_LINK=shared"
        "PROJ_INCLUDES=/usr/include"
        "PROJ_LIBS=/usr/$(get_libdir)"
        "SYSTEM_FONTS=/usr/share/fonts"
        CAIRO="$(usex cairo 1 0)"
        DEBUG="$(usex debug 1 0)"
        XML_DEBUG="$(usex debug 1 0)"
        DEMO="$(usex doc 1 0)"
        SAMPLE_INPUT_PLUGINS="$(usex doc 1 0)"
        "CUSTOM_LDFLAGS=$LDFLAGS"
        "CUSTOM_LDFLAGS+=-L$ED/usr/$(get_libdir)"
    )
    escons "${MYSCONS[@]}" configure
}

src_compile() {
    escons "${MYSCONS[@]}"
}

src_install() {
    escons "${MYSCONS[@]}" DESTDIR="$D" install

    dodoc AUTHORS.md README.md CHANGELOG.md
}

pkg_postinst() {
    elog ""
    elog "See the home page or wiki (https://github.com/mapnik/mapnik/wiki) for more info"
    elog "or the installed examples for the default mapnik ogcserver config."
    elog ""
}
