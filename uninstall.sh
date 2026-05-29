#!/usr/bin/env sh
# Mithraeum unified uninstaller.
#
#   curl -fsSL https://mithraeums.github.io/uninstall.sh | sh                     # interactive menu
#   curl -fsSL https://mithraeums.github.io/uninstall.sh | sh -s -- --all
#   curl -fsSL https://mithraeums.github.io/uninstall.sh | sh -s -- --hako --hake
#
# Optional:
#   --purge      also remove ~/.hako/ (state, credentials, sessions, skills)
#   --models     also remove ollama hako-* models
#   --icons      also remove placed icons / .desktop entries

set -eu

want_hako=0; want_hake=0; want_hakm=0; do_purge=0; do_models=0; do_icons=0
for arg in "$@"; do
	case "$arg" in
		--hako) want_hako=1 ;;
		--hake) want_hake=1 ;;
		--hakm) want_hakm=1 ;;
		--all)  want_hako=1; want_hake=1; want_hakm=1 ;;
		--purge)  do_purge=1 ;;
		--models) do_models=1 ;;
		--icons)  do_icons=1 ;;
		--help|-h) sed -n '2,/^set -eu/p' "$0" | sed 's/^# //; s/^#$//'; exit 0 ;;
		*) echo "unknown flag: $arg" >&2; exit 2 ;;
	esac
done

uname_s="$(uname -s 2>/dev/null || echo unknown)"
is_ish=0
[ -f /etc/alpine-release ] && (uname -a 2>/dev/null | grep -qi 'ish\|iOS') && is_ish=1
[ "${ISH:-0}" = 1 ] && is_ish=1

if [ "$want_hako" = 0 ] && [ "$want_hake" = 0 ] && [ "$want_hakm" = 0 ]; then
	if [ -e /dev/tty ]; then
		echo ""
		echo "  Mithraeum uninstaller"
		echo ""
		echo "    1  hako    the agent"
		echo "    2  hake    the editor"
		echo "    3  hakm    the models suite (script only, not ollama models)"
		echo "    4  all"
		echo "    a  all + --purge --models --icons   (nuke everything)"
		echo ""
		printf "  > "
		read -r ans </dev/tty || ans=""
		case "$ans" in
			a|A) want_hako=1; want_hake=1; want_hakm=1; do_purge=1; do_models=1; do_icons=1 ;;
			*4*|all|ALL) want_hako=1; want_hake=1; want_hakm=1 ;;
			*)
				case " $ans " in *" 1 "*|"1") want_hako=1 ;; esac
				case " $ans " in *" 2 "*|"2") want_hake=1 ;; esac
				case " $ans " in *" 3 "*|"3") want_hakm=1 ;; esac
				;;
		esac
		echo ""
	else
		echo "no products specified. pass --all or one of --hako --hake --hakm" >&2
		exit 2
	fi
fi

remove_bin() {
	bin="$1"
	for prefix in "${PREFIX:-}" "/usr/local" "$HOME/.local" "/opt/local" "/opt"; do
		[ -z "$prefix" ] && continue
		path="${prefix}/bin/${bin}"
		if [ -e "$path" ] || [ -L "$path" ]; then
			rm -f "$path" && echo "  removed: $path"
		fi
	done
}

remove_icons() {
	# Linux: ~/.local/share/applications/<name>.desktop + ~/.local/share/icons/hicolor/*/apps/<name>.png
	for app in hako hake hakm; do
		rm -f "${HOME}/.local/share/applications/${app}.desktop"  2>/dev/null && echo "  removed: ~/.local/share/applications/${app}.desktop" || true
		for d in "${HOME}/.local/share/icons/hicolor"/*/apps; do
			[ -d "$d" ] && rm -f "${d}/${app}.png" 2>/dev/null
		done
	done
	# macOS: ~/Applications/<App>.app   (only if user dragged the .icns into a .app shell)
	for app in Hako Hake Hakm; do
		[ -d "${HOME}/Applications/${app}.app" ] && rm -rf "${HOME}/Applications/${app}.app" && echo "  removed: ~/Applications/${app}.app" || true
	done
}

if [ "$want_hako" = 1 ]; then
	echo ":: removing hako"
	remove_bin hako
fi

if [ "$want_hake" = 1 ]; then
	echo ":: removing hake"
	remove_bin hake
fi

if [ "$want_hakm" = 1 ]; then
	echo ":: removing hakm"
	remove_bin hakm
fi

if [ "$do_models" = 1 ] && command -v ollama >/dev/null 2>&1; then
	echo ":: removing ollama hako-* models"
	ollama list 2>/dev/null | awk 'NR>1 && $1 ~ /^hako-/ {print $1}' | while read -r tag; do
		ollama rm "$tag" >/dev/null 2>&1 && echo "  removed model: $tag" || true
	done
fi

if [ "$do_icons" = 1 ]; then
	echo ":: removing icons"
	remove_icons
fi

if [ "$do_purge" = 1 ]; then
	echo ":: purging ~/.hako/ (state, credentials, sessions, skills)"
	if [ -d "${HOME}/.hako" ]; then
		rm -rf "${HOME}/.hako" && echo "  removed: ~/.hako/"
	fi
	[ -f "${HOME}/.hakorc" ] && rm -f "${HOME}/.hakorc" && echo "  removed: ~/.hakorc"
	# Legacy paths
	[ -d "${HOME}/.hakoc" ] && rm -rf "${HOME}/.hakoc" && echo "  removed: ~/.hakoc/ (legacy)"
fi

echo "done."
[ "$do_models" = 0 ] && [ "$want_hakm" = 1 ] && echo "note: ollama hako-* models kept. add --models to remove them too."
[ "$do_purge"  = 0 ] && echo "note: ~/.hako/ config kept. add --purge to remove it too."
