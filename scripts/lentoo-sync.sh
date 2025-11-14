#!/bin/bash

set -e

version_compare() {
    local v1="$1" # First value 
    local op="$2" # Operator
    local v2="$3" # Second value
    local min=$(printf '%s\n' "$v1" "$v2" | sort -V | head -n1) # Minimal

    case "$op" in
        ">=") [[ "$min" == "$v2" ]] ;;
        "<=") [[ "$min" == "$v1" ]] ;;
        ">")  [[ "$min" == "$v2" && "$v1" != "$v2" ]] ;;
        "<")  [[ "$min" == "$v1" && "$v1" != "$v2" ]] ;;
        "=")  [[ "$v1" == "$v2" ]] ;;
        *)    return 1 ;;
    esac
}

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
    PKGVER=${BASE##*-}
    SRC_PATH="$GENTOO_OVERLAY/$CATEGORY/$NAME"
    DST_PATH="$LENTOO_WORK_OVERLAY/$CATEGORY/$NAME"

    if [[ -d "$SRC_PATH" ]]; then
        echo "→ Found $SRC_PATH"
        mkdir -p "$(dirname "$DST_PATH")"
        echo "📆 Check versions for $NAME"
        if [[ $PKG =~ ^[=\<\>~]+ ]]; then
            OPERATOR=${BASH_REMATCH[0]}
	    fi
        VERSIONS_TO_COPY=()
        for VERSION_READ in $GENTOO_OVERLAY/$CATEGORY/$NAME/*.ebuild; do
            VERSION_READY=${VERSION_READ##*/}
            VERSION_WITHOUT_EXT=${VERSION_READY%.*}
            VERSION=${VERSION_WITHOUT_EXT#*-}
            
            if version_compare "$VERSION" "$OPERATOR" "$PKGVER"; then
                VERSIONS_TO_COPY+=("$VERSION")
            fi 
        done
        echo "These versions will be synced: "
        for VER in "${VERSIONS_TO_COPY[@]}"; do
            echo $VER
        done
        echo ""
        echo "❓ Do you accept (IT OVERWRITE EXISTED FILES)? [Y/n] "
        read CONFIRM
        if [[ $CONFIRM != "n" && $CONFIRM != "N" ]]; then 
            mkdir -p $LENTOO_WORK_OVERLAY/$CATEGORY/$NAME
            sudo chown $USER:$USER -R "$LENTOO_WORK_OVERLAY/" 
            for VER in "${VERSIONS_TO_COPY[@]}"; do
                sudo cp $GENTOO_OVERLAY/$CATEGORY/$NAME/$NAME-$VER.ebuild $LENTOO_WORK_OVERLAY/$CATEGORY/$NAME/$NAME-$VER.ebuild
            done
            echo "✅ Copied to Lentoo overlay."
        fi
    else
        echo "⚠️ Package $PKG not found in Gentoo repo."
    fi
    echo
done

echo "🎉 Done! Lentoo overlay updated."
