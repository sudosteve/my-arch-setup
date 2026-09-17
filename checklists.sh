#!/usr/bin/env bash
# Compare pacmanlist.txt / aurlist.txt against what is actually installed.
#
# Reports:
#   - explicitly installed packages that are missing from the lists
#   - listed packages that are no longer installed
#   - listed packages that are installed only as a dependency
#   - listed packages that no longer exist in the repos / AUR
#   - packages that are in the wrong list (repo pkg in aurlist, AUR pkg in pacmanlist)
#
# Usage: ./checklists.sh [--no-aur]   (--no-aur skips the AUR existence check, which needs network)

set -euo pipefail
cd "$(dirname "$(readlink -f "$0")")"

check_aur=1
[[ "${1:-}" == "--no-aur" ]] && check_aur=0

if [[ -t 1 ]]; then
    bold=$'\e[1m' red=$'\e[31m' green=$'\e[32m' yellow=$'\e[33m' blue=$'\e[34m' dim=$'\e[2m' reset=$'\e[0m'
else
    bold='' red='' green='' yellow='' blue='' dim='' reset=''
fi

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

# Strip comments/blank lines, sort, dedupe.
clean() { sed -e 's/#.*//' -e 's/[[:space:]]//g' "$1" | grep -v '^$' | sort -u; }
clean pacmanlist.txt > "$tmp/list_pacman"
clean aurlist.txt    > "$tmp/list_aur"
sort -u "$tmp/list_pacman" "$tmp/list_aur" > "$tmp/list_all"

pacman -Qqen | sort -u > "$tmp/inst_native_explicit"   # explicit, from repos
pacman -Qqem | sort -u > "$tmp/inst_foreign_explicit"  # explicit, AUR/local
pacman -Qqn  | sort -u > "$tmp/inst_native"            # all repo pkgs
pacman -Qqm  | sort -u > "$tmp/inst_foreign"           # all foreign pkgs
pacman -Qq   | sort -u > "$tmp/inst_all"

section() { printf '\n%s%s%s\n' "$bold" "$1" "$reset"; }
# print_list <color> <marker> <file> [note]
print_list() {
    local color=$1 marker=$2 file=$3 note=${4:-}
    if [[ -s "$file" ]]; then
        while read -r p; do printf '  %s%s %s%s%s\n' "$color" "$marker" "$p" "$reset" "${note:+ $dim$note$reset}"; done < "$file"
    else
        printf '  %s(none)%s\n' "$dim" "$reset"
    fi
}

# --- Installed explicitly but not in any list ---------------------------------
comm -23 "$tmp/inst_native_explicit"  "$tmp/list_all" > "$tmp/missing_native"
comm -23 "$tmp/inst_foreign_explicit" "$tmp/list_all" > "$tmp/missing_foreign"

section "Explicitly installed but NOT in pacmanlist.txt (repo packages):"
print_list "$green" "+" "$tmp/missing_native"

section "Explicitly installed but NOT in aurlist.txt (AUR/foreign packages):"
print_list "$green" "+" "$tmp/missing_foreign"

# --- In list but not installed ------------------------------------------------
comm -23 "$tmp/list_pacman" "$tmp/inst_all" > "$tmp/notinst_pacman"
comm -23 "$tmp/list_aur"    "$tmp/inst_all" > "$tmp/notinst_aur"

section "In pacmanlist.txt but NOT installed:"
print_list "$red" "-" "$tmp/notinst_pacman"

section "In aurlist.txt but NOT installed:"
print_list "$red" "-" "$tmp/notinst_aur"

# --- In list, installed, but only as a dependency ------------------------------
comm -12 "$tmp/list_all" "$tmp/inst_all" \
    | comm -23 - <(sort -u "$tmp/inst_native_explicit" "$tmp/inst_foreign_explicit") > "$tmp/as_dep"
section "Listed but installed only as a dependency (not explicit):"
print_list "$yellow" "~" "$tmp/as_dep" "(pacman -D --asexplicit to fix)"

# --- Wrong list -----------------------------------------------------------------
comm -12 "$tmp/list_aur"    "$tmp/inst_native"  > "$tmp/wrong_aur"
comm -12 "$tmp/list_pacman" "$tmp/inst_foreign" > "$tmp/wrong_pacman"
section "In aurlist.txt but installed from the official repos (move to pacmanlist.txt):"
print_list "$yellow" "?" "$tmp/wrong_aur"
section "In pacmanlist.txt but installed as foreign/AUR (move to aurlist.txt):"
print_list "$yellow" "?" "$tmp/wrong_pacman"

# --- Outdated: listed package no longer exists in repos / AUR -----------------
: > "$tmp/gone_pacman"
while read -r p; do
    pacman -Si "$p" &>/dev/null || echo "$p" >> "$tmp/gone_pacman"
done < "$tmp/list_pacman"
section "In pacmanlist.txt but no longer in the sync repos (run 'pacman -Sy' first if stale):"
print_list "$red" "x" "$tmp/gone_pacman"

if (( check_aur )); then
    : > "$tmp/gone_aur"
    if command -v paru &>/dev/null && [[ -s "$tmp/list_aur" ]]; then
        # paru -Si prints info for each found package; names it can't find are absent.
        { paru -Si --aur $(<"$tmp/list_aur") 2>/dev/null || true; } | awk -F': *' '/^Name/ {print $2}' | sort -u > "$tmp/aur_found"
        comm -23 "$tmp/list_aur" "$tmp/aur_found" > "$tmp/gone_aur"
        section "In aurlist.txt but not found in the AUR:"
        print_list "$red" "x" "$tmp/gone_aur"
    else
        section "AUR existence check skipped (paru not found or aurlist empty)."
    fi
fi

# --- Summary --------------------------------------------------------------------
count() { grep -c . "$1" 2>/dev/null || true; }
section "Summary:"
printf '  %sMissing from lists:%s  %d repo, %d AUR\n' "$blue" "$reset" "$(count "$tmp/missing_native")" "$(count "$tmp/missing_foreign")"
printf '  %sNot installed:%s       %d repo, %d AUR\n' "$blue" "$reset" "$(count "$tmp/notinst_pacman")" "$(count "$tmp/notinst_aur")"
printf '  %sWrong list:%s          %d\n' "$blue" "$reset" "$(( $(count "$tmp/wrong_aur") + $(count "$tmp/wrong_pacman") ))"
printf '  %sNo longer available:%s %d repo' "$blue" "$reset" "$(count "$tmp/gone_pacman")"
(( check_aur )) && printf ', %d AUR' "$(count "${tmp}/gone_aur")"
printf '\n'
