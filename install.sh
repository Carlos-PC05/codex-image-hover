#!/usr/bin/env bash
set -euo pipefail

project=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
tag=rust-v0.170.0
revision=29eb79e9866b3262a777fdf8195c1b9e63684c91
toolchain=1.95.0
jobs=${CARGO_BUILD_JOBS:-4}
destination=${XDG_DATA_HOME:-"$HOME/.local/share"}/codex-image-hover
bin=${CODEX_PREVIEW_BIN_DIR:-"$HOME/.local/bin"}

official_bin=${CODEX_UPSTREAM_BIN_DIR:-}
if [[ -z "$official_bin" ]]; then
    official=$(command -v codex)
    official_bin=$(dirname -- "$official")
    if [[ ! -x "$official_bin/codex-code-mode-host" ]] && command -v mise >/dev/null; then
        official_bin=$(dirname -- "$(mise which codex)")
    fi
fi
if [[ $("$official_bin/codex" --version) != "codex-cli ${tag#rust-v}" ||
      ! -x "$official_bin/codex-exec-server" ||
      ! -x "$official_bin/codex-code-mode-host" ]]; then
    printf 'Set CODEX_UPSTREAM_BIN_DIR to the bin directory of Codex CLI %s.\n' "${tag#rust-v}" >&2
    exit 1
fi
official_bin=$(cd -- "$official_bin" && pwd)

mkdir -p -- "$destination"
build=$(mktemp -d "$destination/.source.XXXXXXXX")
trap 'rm -rf -- "$build"' EXIT
git clone --quiet --depth 1 --branch "$tag" https://github.com/openai/codex.git "$build/codex"
cd "$build/codex"
[[ $(git rev-parse HEAD) == "$revision" ]]
git apply --check "$project/image-hover.patch"
git apply "$project/image-hover.patch"

cd codex-rs
# The release tag stamps workspace manifests but keeps their 0.0.0 lockfile versions.
sed -i "s/^version = \"0.0.0\"$/version = \"${tag#rust-v}\"/" Cargo.lock
rustup toolchain install "$toolchain" --profile minimal
export CARGO_NET_GIT_FETCH_WITH_CLI=true
export CARGO_TARGET_DIR="$build/target"
export CARGO_PROFILE_DEV_DEBUG=0 CARGO_PROFILE_DEV_INCREMENTAL=false
cargo +"$toolchain" build --locked -j "$jobs" -p codex-cli --bin codex
cargo +"$toolchain" test --locked -j "$jobs" -p codex-tui --lib \
    image_hover_enlarges_the_original_and_removes_the_overlay
"$project/install-built.sh" "$CARGO_TARGET_DIR/debug/codex" "$official_bin" "$destination" "$bin"
