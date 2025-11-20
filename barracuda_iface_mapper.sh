#!/bin/sh
# barracuda_iface_mapper.sh
# Copyright (c) Braam & AUTHORS
# Usage: ./barracuda_iface_mapper.sh --dry-run|--apply|--rollback

ACTION="$1"

MODEL=$(/root/scripts/iface_mapper/./hwtool -m)
echo "Model found: ${MODEL}"

MAP_FILE="/root/scripts/iface_mapper/boxnet/${MODEL}.map"

if [ -z "$ACTION" ]; then
    echo "Usage: $0 --dry-run|--apply|--rollback"
    exit 1
fi

if [ ! -f "$MAP_FILE" ]; then
    echo "Map file not found: $MAP_FILE"
    exit 1
fi

#################################
# APPLY = I2EMAP (ethX -> pY)
#################################
apply_mapping() {
    echo "[APPLY] Processing I2EMAP entries…"

    while IFS='=' read -r left right; do
        SRC="${left#I2EMAP_}"
        DST="$right"

        if [ "$ACTION" = "--dry-run" ]; then
            echo "Would rename $SRC → $DST"
        else
            echo "Renaming $SRC → $DST"
            ip link set "$SRC" down
            if ! ip link set "$SRC" name "$DST"; then
                echo "ERROR: rename $SRC → $DST failed"
            fi
            ip link set "$DST" up
        fi
    done < <(grep '^I2EMAP_' "$MAP_FILE")
}

#################################
# ROLLBACK = E2IMAP (pY -> ethX)
#################################
rollback_mapping() {
    echo "[ROLLBACK] Processing E2IMAP entries…"

    while IFS='=' read -r left right; do
        SRC="${left#E2IMAP_}"
        DST="$right"

        if [ "$ACTION" = "--dry-run" ]; then
            echo "Would rename $SRC → $DST"
        else
            echo "Renaming $SRC → $DST"
            ip link set "$SRC" down
            if ! ip link set "$SRC" name "$DST"; then
                echo "ERROR: rename $SRC → $DST failed"
            fi
            ip link set "$DST" up
        fi
    done < <(grep '^E2IMAP_' "$MAP_FILE")
}

#################################
# SELECT ACTION
#################################
case "$ACTION" in
    --dry-run)
	echo
        echo "=== Dry-run (apply) ==="
        apply_mapping
	echo
        echo "=== Dry-run (rollback) ==="
        rollback_mapping
        exit 0
        ;;

    --apply)
        apply_mapping
        echo "[INFO] Restarting networking after apply..."
        /etc/init.d/networking restart
        ;;

    --rollback)
        rollback_mapping
        echo "[INFO] Restarting networking after rollback..."
        /etc/init.d/networking restart
        ;;

    *)
        echo "Unknown option: $ACTION"
        exit 1
        ;;
esac


echo "Done."
exit 0
