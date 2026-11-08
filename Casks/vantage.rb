# Homebrew Cask for Vantage
#
# DISTRIBUTION: This cask is published to Sensey's existing tap,
# korurlabs/homebrew-tap (the same tap that hosts the Kagi CLI formula).
# A single tap hosts both Formula/ and Casks/ — this GUI .app lives under
# Casks/. Users install it with:
#   brew install --cask korurlabs/tap/vantage
# (Homebrew expands "korurlabs/tap" -> "korurlabs/homebrew-tap" automatically.)
#
# ON EACH RELEASE — the release workflow renders this file into the tap with:
#   1. version  — bumped to the new semantic version
#   2. sha256   — computed from the notarized Vantage-<version>.zip
#   3. url      — the version is embedded via #{version} interpolation (automatic)
#
cask "vantage" do
  # ---------------------------------------------------------------------------
  # BUMP THESE ON EACH RELEASE (the release workflow does this automatically)
  # ---------------------------------------------------------------------------
  version "0.12.0"
  sha256 "353c40b0d27c187112602ca37e94c8d16b221d0211dce02ee79d246f464cb0e1"

  #           ^^^  run: shasum -a 256 Vantage-#{version}.zip
  # ---------------------------------------------------------------------------

  # Binary release URL — hosted on the PUBLIC korurlabs/homebrew-tap repo so that
  # unauthenticated users can download it via `brew install --cask`.
  # (Assets on the private korurlabs/vantage repo require auth and cannot be used.)
  # #{version} is substituted automatically by Homebrew at install time.
  url "https://github.com/korurlabs/homebrew-tap/releases/download/v#{version}/Vantage-#{version}.zip"
  name "Vantage"
  desc "Window switcher with Accessibility-powered app cycling (cmd+tab override)"
  homepage "https://github.com/korurlabs/vantage"

  # Livecheck — Homebrew uses this to detect new releases automatically
  # (useful even for personal taps if you run `brew livecheck`).
  livecheck do
    url :url
    strategy :github_latest
  end

  # Minimum macOS version matches the deployment target in project.yml.
  depends_on macos: :sonoma

  # The zip contains Vantage.app at the top level — ditto preserves this layout.
  app "Vantage.app"

  # -------------------------------------------------------------------------
  # Uninstall and zap
  #
  # uninstall quits the running app before removal so the .app can be replaced
  # cleanly on upgrade (Vantage runs as a menu-bar accessory).
  #
  # zap removes user data and preferences that Homebrew won't touch otherwise,
  # including the file-sink log under ~/Library/Logs/Vantage.
  # -------------------------------------------------------------------------
  # The nested link router (Vantage Links.app) stays resident after a link; quit
  # it too, or an upgrade leaves the old one routing links.
  uninstall quit: [
    "com.sensey.vantage",
    "com.sensey.vantage.links",
  ]

  zap trash: [
    "~/Library/Application Support/Vantage",
    "~/Library/Caches/com.sensey.vantage",
    "~/Library/Logs/Vantage",
    "~/Library/Preferences/com.sensey.vantage.plist",
    "~/Library/Preferences/com.sensey.vantage.links.plist",
    "~/Library/Saved Application State/com.sensey.vantage.savedState",
  ]

  # -------------------------------------------------------------------------
  # Accessibility caveat
  #
  # Vantage installs a global CGEventTap to intercept cmd+tab. After
  # installation the user must grant Accessibility permission once:
  #   System Settings → Privacy & Security → Accessibility → Vantage → ON
  #
  # With a Developer ID signature (which this cask requires) the TCC grant
  # is stable across updates — the cdhash is consistent because the signing
  # identity does not change between builds.
  # -------------------------------------------------------------------------
  caveats <<~EOS
    Vantage requires Accessibility permission to intercept cmd+tab:

      System Settings → Privacy & Security → Accessibility → Vantage (toggle ON)

    You only need to do this once. The permission persists across updates.
  EOS
end
