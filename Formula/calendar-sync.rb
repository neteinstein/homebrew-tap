# Homebrew formula for Calendar Sync. The source copy lives in the app repository at
# packaging/homebrew/calendar-sync.rb; keep the two in step.
#
# Releasing a new version: point `url` at the new commit (or tag) archive, update `version`
# to match Support/Info.plist, and set `sha256` to the output of
#   curl -L <url> | shasum -a 256
class CalendarSync < Formula
  desc "Menu bar app that copies secondary-calendar meetings into your main calendar"
  homepage "https://github.com/neteinstein/Calendar-Sync"
  url "https://github.com/neteinstein/Calendar-Sync/archive/4bb6719ac5530a23d6b7264f9c8f32f0c58a5798.tar.gz"
  version "1.1.16"
  sha256 "a14f5dc7ab0fd40bf631894f28cbcf4d03665b35b0905ba5fb55bf7ae6c489dc"
  license "SUL-1.0"
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

      The first time it runs, the app links itself into ~/Applications,
      unless /Applications already has it. The link goes through
      #{opt_prefix}, so it opens the newest version
      after brew upgrade. Finder and the Dock treat it as the app; Spotlight
      and Launchpad don't list linked apps. Remove the link and it stays
      removed. To link it into /Applications instead, from an account that
      can write there:
        ln -s "#{opt_prefix}/Calendar Sync.app" /Applications/
      brew uninstall leaves the link behind:
        rm ~/Applications/"Calendar Sync.app"

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

      brew upgrade doesn't restart a running Calendar Sync: it keeps
      running the old version until it quits. If you started it with
      brew services, restart it with:
        brew services restart calendar-sync
      If you opened it yourself, quit it and open the new version with:
        pkill -x CalendarSync; sleep 1; open "#{opt_prefix}/Calendar Sync.app"

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
