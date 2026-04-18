# Copyright 2026 rafalkozikowski735@gmail.com
# Distributed under the terms of the GNU General Public License v2

EAPI="8"
PYTHON_COMPAT=( python3_{11..14} )

MY_PN="pgadmin4"
MY_PV="${PV}"

inherit python-any-r1 optfeature
DESCRIPTION="Feature-rich, open-source administration and development platform for PostgreSQL, the most advanced open source database in the world."
HOMEPAGE="https://www.pgadmin.org/"
SRC_URI="https://ftp.postgresql.org/pub/pgadmin/${MY_PN}/v${MY_PV}/source/${MY_PN}-${MY_PV}.tar.gz"
KEYWORDS="~amd64"

LICENSE="PostgreSQL"
SLOT="$(ver_cut 1)"

IUSE="kerberos doc server desktop"

RDEPEND="
    dev-python/flask
    
    net-libs/nodejs
"

DEPEND="${RDEPEND}"

BDEPEND=""

PGADMIN_INSTALLDIR="/usr/lib/${PN}-${SLOT}"
PGADMIN_DATADIR="/var/lib/${PN}"
PGADMIN_CONFDIR="/etc/${PN}"
PGADMIN_LOGDIR="/var/log/${PN}"

pkg_setup() {
    python-any-r1_pkg_setup
}

src_prepare() {
    default

    # Adjust the default config to use proper Gentoo paths
    sed -i \
        -e "s|DATA_DIR = .*|DATA_DIR = '${PGADMIN_DATADIR}'|" \
        -e "s|LOG_FILE = .*|LOG_FILE = '${PGADMIN_LOGDIR}/pgadmin4.log'|" \
        -e "s|SQLITE_PATH = .*|SQLITE_PATH = os.path.join(DATA_DIR, 'pgadmin4.db')|" \
        -e "s|SESSION_DB_PATH = .*|SESSION_DB_PATH = os.path.join(DATA_DIR, 'sessions')|" \
        -e "s|STORAGE_DIR = .*|STORAGE_DIR = os.path.join(DATA_DIR, 'storage')|" \
        web/config.py || die "sed on config.py failed"
}
