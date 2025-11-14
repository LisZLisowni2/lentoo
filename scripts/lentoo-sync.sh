#!/bin/bash

set -e

SKIP_SYNC=false
REQUIRE_CONFIRMATION=true

case "$@" in
    "-s" | "--skip-sync")
        SKIP_SYNC=true
        ;;
    "-y" | "--yes")
        REQUIRE_CONFIRMATION=false
        ;;
esac

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LENTOO_WORK_OVERLAY="$SCRIPT_DIR/.."
GENTOO_OVERLAY="/var/db/repos/gentoo"

if ! $SKIP_SYNC; then
    echo "🔄 Syncing Gentoo repository..."
    sudo emaint sync --repo gentoo || sudo emerge --sync
fi

echo $LENTOO_WORK_OVERLAY/packages.list

read -r PKGS <<< $(tr '\n' ' ' < "$LENTOO_WORK_OVERLAY/packages.list")

for pkg in "${PKGS[@]}"; do
    PKG=$(echo $pkg | xargs)
    [[ -z "$PKG" ]] && continue

    echo "📦 Checking $PKG..."
    BASIC=$(echo $PKG | cut -d ">" -f2 | cut -d "<" -f2 | cut -d "=" -f2)
    CATEGORY=${BASIC%%/*}
    BASE=${BASIC##*/}
    NAME=${BASE%%-*}
    PKGVER=${BASE##*/}
    SRC_PATH="$GENTOO_OVERLAY/$CATEGORY/$NAME"
    DST_PATH="$LENTOO_WORK_OVERLAY/$CATEGORY/$NAME"

    if [[ -d "$SRC_PATH" ]]; then
        echo "→ Found $SRC_PATH"
        mkdir -p "$(dirname "$DST_PATH")"
        echo "📆 Check versions for $NAME"
        VERSIONS_RAW=$(ls "$GENTOO_OVERLAY/$CATEGORY/$NAME/" | grep ebuild | sed 's/ /;/')
        IFS=' ' read -ra VERSIONS <<< "$VERSIONS_RAW"
        if [[ $VERSION =~ ^[=\<\>~]+ ]]; then
            op=${BASH_REMATCH[0]}
            echo $op
        for version in "${VERSIONS[@]}"; do
            VERSION_WITHOUT_EXT=${version%.*}
            VERSION_READY=${VERSION_WITHOUT_EXT#*-}
            # certain version
	    fi;
        done
        sudo rsync -av -n "$SRC_PATH/" "$DST_PATH/"
        echo "❓ Do you accept? [Y/n] "
        read CONFIRM
        if [[ $CONFIRM != "n" && $CONFIRM != "N" ]]; then 
            sudo rsync -a "$SRC_PATH/" "$DST_PATH/"
            sudo chown $USER:$USER -R "$LENTOO_WORK_OVERLAY/" 
            echo "✅ Copied to Lentoo overlay."
        fi
    else
        echo "⚠️ Package $PKG not found in Gentoo repo."
    fi
    echo
done

echo "🎉 Done! Lentoo overlay updated."
