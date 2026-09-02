# Homebrew Cask, not Formula: this ships a packaged Electron GUI app, not
# something built from source or a CLI binary. Casks are macOS-only --
# Homebrew on Linux does not install GUI .app bundles this way, so this file
# has no bearing on the Arch/AUR path (see packaging/aur/PKGBUILD).
cask "beamlynx" do
  version "0.11.0"
  # `brew bump-cask-pr` (or a hand run of `shasum -a 256`) recomputes this
  # against the real dmg -- update this by hand per release until the tap
  # repo's bump automation exists.
  sha256 "44fb940cb133140bbe891d9522835167076d301f144e049a8e1773cc486e5b2e"

  url "https://github.com/beamlynx/beamlynx-desktop/releases/download/#{version}/beamlynx-#{version}.dmg"
  name "beamlynx"
  desc "Desktop app bundling the pine-lang server and beamlynx-ui UI, no Docker required"
  homepage "https://github.com/beamlynx/beamlynx-desktop"

  # GitHub's macos-latest runner has been Apple Silicon (arm64) since 2024,
  # and electron-builder.yml's mac.target doesn't set an explicit arch
  # array, so the published dmg is arm64-only. Decided to ship arm64-only
  # for now rather than add an Intel (x64) leg to release.yml's package
  # matrix first -- most Macs from the last ~4 years are arm64, and this
  # restriction means an Intel colleague gets a clear "not supported"
  # instead of a cask that installs but doesn't launch. Revisit if that
  # turns out to matter.
  depends_on arch: :arm64

  app "beamlynx.app"

  # electron-updater is bundled and active (src/main/auto-update.ts calls
  # checkForUpdatesAndNotify unconditionally) -- it will keep the app
  # current independent of Homebrew. Setting auto_updates true stops
  # `brew upgrade --cask` from fighting it by reinstalling over a
  # newer-than-catalog copy.
  auto_updates true

  # As of 0.2.2, release.yml signs (Developer ID Application cert) and
  # notarizes (notarytool) the mac build -- see SIGNING.md. Homebrew Cask
  # still quarantines downloads by default, but a signed+notarized app
  # passes Gatekeeper's assessment on that quarantine flag normally, so no
  # caveat/manual-open step should be needed anymore. Not yet confirmed on
  # a real, previously-untrusted Mac -- if Gatekeeper still blocks first
  # launch for some user, that's a real signal worth investigating rather
  # than assuming this comment is right.

  zap trash: [
    "~/Library/Application Support/beamlynx",
    "~/Library/Saved Application State/com.beamlynx.desktop.savedState",
    "~/Library/Preferences/com.beamlynx.desktop.plist",
    "~/Library/Logs/beamlynx",
  ]
end
