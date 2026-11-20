#!/usr/bin/env bash
set -euo pipefail

source_dir=$1
destination=$2
bin=$3

mkdir -p -- "$destination" "$bin"
stage=$(mktemp -d "$destination/build.XXXXXXXX")
trap 'rm -rf -- "$stage"' EXIT
for executable in codex codex-exec-server codex-code-mode-host; do
    install -m 755 -- "$source_dir/$executable" "$stage/$executable"
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
