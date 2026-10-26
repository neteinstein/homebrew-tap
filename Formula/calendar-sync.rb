# Homebrew formula for Calendar Sync. The source copy lives in the app repository at
# packaging/homebrew/calendar-sync.rb; keep the two in step.
#
# Releasing a new version: point `url` at the new commit (or tag) archive, update `version`
# to match Support/Info.plist, and set `sha256` to the output of
#   curl -L <url> | shasum -a 256
class CalendarSync < Formula
  desc "Menu bar app that copies client-calendar meetings into your main calendar"
  homepage "https://github.com/neteinstein/Calendar-Sync"
  url "https://github.com/neteinstein/Calendar-Sync/archive/4bf8f21f11ded476006019a71b8b25f885eb5311.tar.gz"
  version "0.2.2"
  sha256 "cd53549b8069f46b5722bffa023e910224e87208f2b79d396e1c2860ef4ae7ec"
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

      To start it at every login, use brew services (below) rather than
      "Open at login" in the app's Settings. The service runs the app from
      #{opt_prefix}, which keeps pointing at the newest version
      after brew upgrade. Leave the in-app switch off, or two copies start.

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
