# Homebrew formula for Calendar Sync. The source copy lives in the app repository at
# packaging/homebrew/calendar-sync.rb; keep the two in step.
#
# Releasing a new version: point `url` at the new commit (or tag) archive, update `version`
# to match Support/Info.plist, and set `sha256` to the output of
#   curl -L <url> | shasum -a 256
class CalendarSync < Formula
  desc "Menu bar app that copies client-calendar meetings into your main calendar"
  homepage "https://github.com/neteinstein/Calendar-Sync"
  url "https://github.com/neteinstein/Calendar-Sync/archive/e2980babf6fd70058cb11df1f079c6c9a217f7a0.tar.gz"
  version "1.1.1"
  sha256 "a7363396f5c9ddc08727ce41965671e8613deace5c29728237159e84f02188d9"
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
      Calendar Sync is a menu bar app. To start it once:
        open "#{opt_prefix}/Calendar Sync.app"

      To have it in your Applications folder too, link it there once:
        ln -s "#{opt_prefix}/Calendar Sync.app" /Applications/
      The link goes through #{opt_prefix}, so it opens the newest version
      after brew upgrade. Finder and the Dock treat it as the app; Spotlight
      and Launchpad don't list linked apps. brew uninstall leaves it behind:
        rm "/Applications/Calendar Sync.app"

      To start it at every login, use brew services (below) rather than
      "Open at login" in the app's Settings. The service runs the app from
      #{opt_prefix}, which keeps pointing at the newest version
      after brew upgrade. Leave the in-app switch off: only one copy runs at a
      time, so a second login item would just start and quit.

      Run brew services as the user who logs in to the desktop, even when
      Homebrew belongs to a separate admin account: from an account that
      isn't logged in, it fails with "Domain does not support specified
      action". If Homebrew then refuses to load the formula from an
      untrusted tap, run this from your account first:
        brew trust --formula neteinstein/tap/calendar-sync

      brew upgrade doesn't restart the running app. Do that with:
        brew services restart calendar-sync

      The build is ad-hoc signed, so macOS asks for calendar access again
      after each upgrade. Your settings are kept.
    EOS
  end

  service do
    run opt_prefix/"Calendar Sync.app/Contents/MacOS/CalendarSync"
    process_type :interactive
  end

  test do
    assert_path_exists prefix/"Calendar Sync.app/Contents/MacOS/CalendarSync"
  end
end
