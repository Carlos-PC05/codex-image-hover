# Codex Image Hover

A patch for the Codex CLI that enlarges a local image when you move the pointer over its thumbnail. It works on images pasted into an unsent draft and on image thumbnails rendered in the conversation. The preview is clipped to the available terminal space and uses the original image. Moving off the thumbnail removes the preview without moving the conversation.

## Install on Linux

Use Ghostty or Kitty directly with Kitty graphics support. The first version targets the fullscreen CLI and local Codex sessions. The terminal must forward mouse motion. Terminal scrollback mode, tmux image passthrough, Sixel and remote image URLs are outside this version's scope.

Install the official Codex CLI **0.170.0** first. The installer copies its two companion executables and builds the patched CLI. Set `CODEX_UPSTREAM_BIN_DIR` if the official executables are outside your command lookup path.

Install Git, Bash, Rustup and your distribution's native build dependencies for Codex, including a C/C++ toolchain, pkg-config and libcap headers. The first build downloads and compiles the upstream Rust workspace.

```sh
git clone https://github.com/Carlos-PC05/codex-image-hover.git
cd codex-image-hover
./install.sh
codex-preview
```

The launcher defaults to `~/.local/bin/codex-preview` and enables the fullscreen transcript for that invocation. It uses your existing Codex configuration and login. Paste an image to try the draft preview. In the transcript, move the pointer onto a rendered thumbnail. Run `codex-preview resume` to reopen a conversation.

## Codex updates and removal

The patch is pinned to Codex CLI **0.170.0**. Updating your official `codex` leaves this build at that version. To port the patch, update the pinned tag and commit, check that it applies, and run the included hover regression test against the new upstream source. Rebuild and reinstall to pick up new Codex fixes.

From the patched upstream `codex-rs` directory, run the focused regression test with:

```sh
cargo +1.95.0 test --locked -p codex-tui --lib image_hover_enlarges_the_original_and_removes_the_overlay
```

Remove `~/.local/bin/codex-preview` and `${XDG_DATA_HOME:-~/.local/share}/codex-image-hover` to uninstall the patch.

The patch and installer are distributed under Apache-2.0. Codex is maintained by OpenAI.
