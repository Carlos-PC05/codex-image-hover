#!/usr/bin/env bash
set -euo pipefail

codex_binary=$1
helper_dir=$2
destination=$3
bin=$4

mkdir -p -- "$destination" "$bin"
stage=$(mktemp -d "$destination/build.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
install -m 755 -- "$codex_binary" "$stage/codex"
for executable in codex-exec-server codex-code-mode-host; do
    install -m 755 -- "$helper_dir/$executable" "$stage/$executable"
done
"$stage/codex" --version

launcher=$(mktemp "$bin/.codex-preview.XXXXXXXX")
trap 'rm -f -- "$launcher"; rm -rf -- "$stage"' EXIT
# Quote the build location even when it contains spaces.
printf '#!/usr/bin/env bash\nexec %q -c tui.fullscreen_transcript=true -c tui.alternate_screen=always "$@"\n' \
    "$stage/codex" > "$launcher"
chmod 755 "$launcher"
mv -fT -- "$launcher" "$bin/codex-preview"
trap - EXIT
printf 'Installed %s\n' "$bin/codex-preview"
