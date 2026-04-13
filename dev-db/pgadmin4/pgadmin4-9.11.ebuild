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
    ${PYTHON_DEPS}
    dev-python/flask[${PYTHON_USEDEP}]
    dev-python/flask-login[${PYTHON_USEDEP}]
    dev-python/flask-sqlalchemy[${PYTHON_USEDEP}]
    dev-python/flask-wtf[${PYTHON_USEDEP}]
    dev-python/flask-mail[${PYTHON_USEDEP}]
    dev-python/flask-migrate[${PYTHON_USEDEP}]
    dev-python/flask-paranoid[${PYTHON_USEDEP}]
    dev-python/flask-compress[${PYTHON_USEDEP}]
    dev-python/flask-babel[${PYTHON_USEDEP}]
    dev-python/wtforms[${PYTHON_USEDEP}]
    dev-python/sqlalchemy[${PYTHON_USEDEP}]
    dev-python/psycopg:2[${PYTHON_USEDEP}]
    dev-python/psycopg:3[${PYTHON_USEDEP}]
    dev-python/cryptography[${PYTHON_USEDEP}]
    dev-python/paramiko[${PYTHON_USEDEP}]
    dev-python/bcrypt[${PYTHON_USEDEP}]
    dev-python/pyotp[${PYTHON_USEDEP}]
    dev-python/qrcode[${PYTHON_USEDEP}]
    dev-python/pillow[${PYTHON_USEDEP}]
    dev-python/simplejson[${PYTHON_USEDEP}]
    dev-python/user-agents[${PYTHON_USEDEP}]
    dev-python/dnspython[${PYTHON_USEDEP}]
    dev-python/sshtunnel[${PYTHON_USEDEP}]
    dev-python/ldap3[${PYTHON_USEDEP}]
    dev-python/gssapi[${PYTHON_USEDEP}]
    kerberos? ( dev-python/flask-kerberos[${PYTHON_USEDEP}] )
    server? ( acct-user/pgadmin acct-group/pgadmin )
"

DEPEND="${RDEPEND}"

BDEPEND="
    ${PYTHON_DEPS}
    doc? (
        dev-python/sphinx[${PYTHON_USEDEP}]
        dev-python/sphinxcontrib-youtube[${PYTHON_USEDEP}]
    )
"

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
