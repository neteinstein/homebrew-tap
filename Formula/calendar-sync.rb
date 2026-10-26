# Homebrew formula for Calendar Sync. The source copy lives in the app repository at
# packaging/homebrew/calendar-sync.rb; keep the two in step.
#
# Releasing a new version: point `url` at the new commit (or tag) archive, update `version`
# to match Support/Info.plist, and set `sha256` to the output of
#   curl -L <url> | shasum -a 256
class CalendarSync < Formula
  desc "Menu bar app that copies client-calendar meetings into your main calendar"
  homepage "https://github.com/neteinstein/Calendar-Sync"
  url "https://github.com/neteinstein/Calendar-Sync/archive/80f1aa88d2bdd8a29f15a3fc372621407afebe86.tar.gz"
  version "0.2.0"
  sha256 "e9f81bc33c7e3918769fb8c67b8576d618290ceee328c07310e69f78d702c620"
  license "PolyForm-Noncommercial-1.0.0"
  head "https://github.com/neteinstein/Calendar-Sync.git", branch: "main"

  depends_on macos: :sonoma

  def install
    # Builds with the system Swift toolchain (Xcode 15+ command line tools are enough)
    # and ad-hoc signs, exactly like a manual source build. SwiftPM's own sandbox can't
    # nest inside Homebrew's build sandbox ("sandbox_apply: Operation not permitted").
    system "scripts/build-app.sh", "--disable-sandbox"
    prefix.install "build/Calendar Sync.app"
  end

  def caveats
    <<~EOS
      Calendar Sync is a menu bar app. Start it with:
        open "#{opt_prefix}/Calendar Sync.app"

      If you use "Open at login", copy it into /Applications instead, so the
      login item survives upgrades:
        cp -a "#{opt_prefix}/Calendar Sync.app" /Applications/

      The build is ad-hoc signed, so macOS asks for calendar access again
      after each upgrade. Your settings are kept.
    EOS
  end

  test do
    assert_path_exists prefix/"Calendar Sync.app/Contents/MacOS/CalendarSync"
  end
end
