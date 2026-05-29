#!/usr/bin/env sh
# Mithraeum installer proxy — hakm + hako stock-wrap models.
#   curl -fsSL https://mithraeums.github.io/hakm.sh | sh
#
# Pulls the hakm CLI + the 3B sho-stock + 7B koi-mini-stock Modelfiles.
# Requires ollama on PATH (until hakm-server v0.1.7 ships).
#
# Env:
#   PREFIX=/usr/local      install dir (defaults to ~/.local if not writable)
#   SKIP_MODELS=1          install hakm only, skip pulling base + creating tags
#   ONLY=sho|koi-mini      install only one stock-wrap (skip the other)

set -eu

is_ish=0
[ -f /etc/alpine-release ] && (uname -a 2>/dev/null | grep -qi 'ish\|iOS') && is_ish=1
[ "${ISH:-0}" = 1 ] && is_ish=1

if [ "$is_ish" = 1 ]; then
	echo "iSh detected." >&2
	echo "  hakm script installs fine, but ollama cannot run on iSh (no GPU, no Metal)." >&2
	echo "  Models will not be pullable until hakm-server (v0.1.7) ships." >&2
	echo "  Installing hakm only; skipping model fetch." >&2
	SKIP_MODELS=1
fi

if [ "${SKIP_MODELS:-0}" != 1 ]; then
	command -v ollama >/dev/null 2>&1 || {
		echo "ollama not found. install first: https://ollama.com/download" >&2
		exit 1
	}
fi

PREFIX="${PREFIX:-}"
if [ -z "$PREFIX" ]; then
	if [ "$is_ish" = 1 ]; then
		PREFIX="${HOME}/.local"
	elif [ -w "/usr/local/bin" ] || [ "$(id -u)" = "0" ]; then
		PREFIX=/usr/local
	else
		PREFIX="${HOME}/.local"
	fi
fi
mkdir -p "${PREFIX}/bin"

tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

echo "fetching hakm..."
curl -fsSL "https://raw.githubusercontent.com/mithraeums/hako/main/hakm" -o "${tmp}/hakm"
install -m 0755 "${tmp}/hakm" "${PREFIX}/bin/hakm"
echo "installed: ${PREFIX}/bin/hakm"

if [ "${SKIP_MODELS:-0}" = 1 ]; then
	echo "done. (models skipped)"
	exit 0
fi

ONLY="${ONLY:-}"
want_sho=1; want_mini=1
case "$ONLY" in
	sho)      want_mini=0 ;;
	koi-mini) want_sho=0  ;;
	"")       ;;
	*) echo "unknown ONLY=$ONLY (expected sho or koi-mini)" >&2; exit 2 ;;
esac

if [ "$want_sho" = 1 ]; then
	echo "pulling Qwen2.5-Coder-3B base + creating hako-sho-stock..."
	mkdir -p "${tmp}/sho/models/hako-sho-stock"
	curl -fsSL "https://raw.githubusercontent.com/mithraeums/hako/main/sho/models/hako-sho-stock/Modelfile" \
		-o "${tmp}/sho/models/hako-sho-stock/Modelfile"
	ollama pull qwen2.5-coder:3b-instruct
	(cd "${tmp}/sho/models/hako-sho-stock" && ollama create hako-sho-stock -f Modelfile)
fi

if [ "$want_mini" = 1 ]; then
	echo "pulling Qwen2.5-Coder-7B base + creating hako-koi-mini-stock..."
	mkdir -p "${tmp}/koi/models/hako-koi-mini-stock"
	curl -fsSL "https://raw.githubusercontent.com/mithraeums/hako/main/koi/models/hako-koi-mini-stock/Modelfile" \
		-o "${tmp}/koi/models/hako-koi-mini-stock/Modelfile"
	ollama pull qwen2.5-coder:7b-instruct
	(cd "${tmp}/koi/models/hako-koi-mini-stock" && ollama create hako-koi-mini-stock -f Modelfile)
fi

echo "done. try:"
[ "$want_sho"  = 1 ] && echo "  hakm run sho 'hello'"
[ "$want_mini" = 1 ] && echo "  hakm run koi-mini 'hello'"
