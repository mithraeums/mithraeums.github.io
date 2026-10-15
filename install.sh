#!/usr/bin/env sh
# Mithraeum unified installer.
#
#   curl -fsSL https://mithraeums.github.io/install.sh | sh                    # interactive menu
#   curl -fsSL https://mithraeums.github.io/install.sh | sh -s -- --all        # install all three
#   curl -fsSL https://mithraeums.github.io/install.sh | sh -s -- --hako --hake
#   curl -fsSL https://mithraeums.github.io/install.sh | sh -s -- --uninstall  # remove instead
#
# Env overrides:
#   PREFIX=/usr/local              install dir (defaults to ~/.local if not writable)
#   VERIFY=0                       skip sha256 verify (default 1, forwarded to per-repo scripts)
#
# Programs:
#   hako   the agent          (mithraeums/hako-code,  binary `hako`)
#   hake   the editor         (mithraeums/hako-edit,  binary `hake`)
#   hakm   the engine         (mithraeums/hako,       native C runtime for the hako models)

set -eu

want_hako=0; want_hake=0; want_hakm=0; want_uninstall=0
for arg in "$@"; do
	case "$arg" in
		--hako)      want_hako=1 ;;
		--hake)      want_hake=1 ;;
		--hakm)      want_hakm=1 ;;
		--all)       want_hako=1; want_hake=1; want_hakm=1 ;;
		--uninstall) want_uninstall=1 ;;
		--help|-h)
			sed -n '2,/^set -eu/p' "$0" | sed 's/^# //; s/^#$//'
			exit 0 ;;
		*) echo "unknown flag: $arg" >&2; exit 2 ;;
	esac
done

uname_s="$(uname -s 2>/dev/null || echo unknown)"
uname_m="$(uname -m 2>/dev/null || echo unknown)"
is_ish=0
# iSh: Alpine running under iOS. No /usr/local writable. No GPU. musl, 32-bit x86.
if [ -f /etc/alpine-release ] && (uname -a 2>/dev/null | grep -qi 'ish\|iOS') ; then is_ish=1; fi
[ "${ISH:-0}" = 1 ] && is_ish=1
case "$uname_s" in
	MINGW*|MSYS*|CYGWIN*) os_label=windows ;;
	Darwin*) os_label=macos ;;
	Linux*)  os_label=linux ;;
	FreeBSD*) os_label=freebsd ;;
	*) os_label="$uname_s" ;;
esac
[ "$is_ish" = 1 ] && os_label=ish

# Interactive menu when piped to a TTY without flags.
if [ "$want_hako" = 0 ] && [ "$want_hake" = 0 ] && [ "$want_hakm" = 0 ] && [ "$want_uninstall" = 0 ]; then
	if [ -e /dev/tty ]; then
		echo ""
		echo "  Mithraeum installer  ${os_label}/${uname_m}"
		echo ""
		echo "  Select programs. Enter numbers separated by spaces."
		echo "  Press Enter for [1] (hako, the agent)."
		echo ""
		echo "    1  hako    the agent"
		echo "    2  hake    the editor"
		echo "    3  hakm    the engine (native, no ollama; builds from source on iSh)"
		echo "    4  all"
		echo "    u  uninstall instead"
		echo ""
		printf "  > "
		read -r ans </dev/tty || ans=""
		ans="${ans:-1}"
		case "$ans" in
			*u*|*U*) want_uninstall=1 ;;
			*4*|all|ALL) want_hako=1; want_hake=1; want_hakm=1 ;;
			*)
				case " $ans " in *" 1 "*|"1") want_hako=1 ;; esac
				case " $ans " in *" 2 "*|"2") want_hake=1 ;; esac
				case " $ans " in *" 3 "*|"3") want_hakm=1 ;; esac
				;;
		esac
		echo ""
	else
		# Non-TTY (piped to a non-interactive shell): default to hako only.
		want_hako=1
	fi
fi

resolve_prefix() {
	if [ -n "${PREFIX:-}" ]; then echo "$PREFIX"; return; fi
	if [ "$is_ish" = 1 ]; then echo "${HOME}/.local"; return; fi
	if [ -w "/usr/local/bin" ] || [ "$(id -u)" = "0" ]; then echo /usr/local; else echo "${HOME}/.local"; fi
}

need() {
	command -v "$1" >/dev/null 2>&1 || {
		echo "missing dependency: $1" >&2
		if [ "$is_ish" = 1 ]; then echo "  iSh: apk add $1" >&2
		else echo "  install $1 and re-run" >&2; fi
		return 1
	}
}

PREFIX="$(resolve_prefix)"
export PREFIX
mkdir -p "${PREFIX}/bin"

if [ "$want_uninstall" = 1 ]; then
	exec curl -fsSL "https://mithraeums.github.io/uninstall.sh" | sh
fi

need curl || exit 1
if [ "$is_ish" = 1 ]; then
	command -v cc >/dev/null 2>&1 || { echo "iSh builds from source: apk add build-base git curl" >&2; exit 1; }
	need make || exit 1
	need git || exit 1
fi

echo "  installing into: ${PREFIX}/bin"
echo "  platform: ${os_label}/${uname_m}"
echo ""

# Per-repo install.sh handles: OS detection, sha256 verify, icon placement
# (where supported), Gatekeeper xattr strip on macOS, PATH hint.
# Unified installer selects + delegates. Where there is no release binary
# (iSh), each per-repo script builds from source: it needs a compiler, make
# and git, so on iSh we check for them here, before the first download.

if [ "$want_hako" = 1 ]; then
	echo ":: hako (the agent)"
	curl -fsSL "https://raw.githubusercontent.com/mithraeums/hako-code/main/install.sh" | sh
	echo ""
fi

if [ "$want_hake" = 1 ]; then
	echo ":: hake (the editor)"
	curl -fsSL "https://raw.githubusercontent.com/mithraeums/hako-edit/main/install.sh" | sh
	echo ""
fi

if [ "$want_hakm" = 1 ]; then
	echo ":: hakm (the engine — native C, no ollama)"
	# A release binary where one exists; on iSh (32-bit x86) it builds from
	# source, which is a couple of minutes. Weights are pulled separately.
	curl -fsSL "https://mithraeums.github.io/hakm.sh" | sh
	echo ""
fi

echo "done."
[ "$want_hako" = 1 ] && echo "  try: hako"
[ "$want_hake" = 1 ] && echo "  try: hake"
[ "$want_hakm" = 1 ] && echo "  try: hakm pull hako-sho"
case ":${PATH}:" in
	*":${PREFIX}/bin:"*) ;;
	*) echo ""
	   echo "note: ${PREFIX}/bin not in PATH. add to your shell rc:"
	   echo "    export PATH=\"${PREFIX}/bin:\$PATH\"" ;;
esac
