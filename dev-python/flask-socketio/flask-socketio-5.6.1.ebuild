# Copyright 1999-2026 Rafał Kozikowski
# Distributed under the terms of the GNU General Public License v2

EAPI=8

DISTUTILS_USE_PEP517=flit
PYTHON_COMPAT=( python3_{11..14} pypy3_11 )

inherit distutils-r1 git-r3

HOMEPAGE="https://github.com/miguelgrinberg/Flask-SocketIO"
DESCRIPTION="A microframework based on Werkzeug, Jinja2 and good intentions"
EGIT_REPO_URI="https://github.com/miguelgrinberg/Flask-SocketIO/archive/refs/tags/v5.6.1.tar.gz"

LICENSE="MIT"
SLOT="0"
IUSE=""

RDEPEND="
	dev-python/flask
"
BDEPEND="${RDEPEND}"

distutils_enable_tests pytest
