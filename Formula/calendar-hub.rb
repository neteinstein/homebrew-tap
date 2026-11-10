# Homebrew formula for Calendar Hub (formula calendar-sync, app Calendar Sync, up to 2.0.19).
# The source copy lives in the app repository at packaging/homebrew/calendar-hub.rb; keep the
# two in step.
#
# Releasing a new version: point `url` at the new commit (or tag) archive, update `version`
# to match Support/Info.plist, and set `sha256` to the output of
#   curl -L <url> | shasum -a 256
class CalendarHub < Formula
  desc "Menu bar app that copies secondary-calendar meetings into your main calendar"
  homepage "https://github.com/neteinstein/Calendar-Sync"
  url "https://github.com/neteinstein/Calendar-Sync/archive/54e69b467694e8f0be134e701fb95938b8561edb.tar.gz"
  version "2.0.20"
  sha256 "3eb28adc113fe9e0a7f55e88bdbb3eb084da67a7f0fe5ccf93a7ea661659793c"
  license "SUL-1.0"
  head "https://github.com/neteinstein/Calendar-Sync.git", branch: "main"

  depends_on macos: :sonoma

  def install
    # Builds with the system Swift toolchain (Xcode 15+ command line tools are enough)
    # and ad-hoc signs, exactly like a manual source build. SwiftPM's own sandbox can't
    # nest inside Homebrew's build sandbox ("sandbox_apply: Operation not permitted").
    system "scripts/build-app.sh", "--disable-sandbox"
    prefix.install "build/Calendar Hub.app"
    # Until 2.0.19 the app was Calendar Sync, formula calendar-sync. Its update script and
    # ~/Applications link open "Calendar Sync.app" under the opt path, which Homebrew keeps
    # pointing here after the rename, so that name opens Calendar Hub too.
    prefix.install_symlink prefix/"Calendar Hub.app" => "Calendar Sync.app"
  end

  def caveats
    <<~EOS
      Calendar Hub is a menu bar app. To start it once:
        open "#{opt_prefix}/Calendar Hub.app"

      The first time it runs, the app links itself into ~/Applications,
      unless /Applications already has it. The link goes through
      #{opt_prefix}, so it opens the newest version
      after brew upgrade. Finder and the Dock treat it as the app; Spotlight
      and Launchpad don't list linked apps. Remove the link and it stays
      removed. To link it into /Applications instead, from an account that
      can write there:
        ln -s "#{opt_prefix}/Calendar Hub.app" /Applications/
      brew uninstall leaves the link behind:
        rm ~/Applications/"Calendar Hub.app"

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
        brew trust --formula neteinstein/tap/calendar-hub

      brew upgrade doesn't restart a running Calendar Hub: it keeps
      running the old version until the new one starts, which has the old
      copy quit and takes its place. If you started it with brew services:
        brew services restart calendar-hub
      If you opened it yourself:
        open "#{opt_prefix}/Calendar Hub.app"

      Coming from calendar-sync (the app's name up to 2.0.19)? Calendar Hub
      brings your settings, tasks and Outlook sign-in across the first time
      it runs. brew services doesn't move the old service, so start the new
      one and remove the old:
        brew services start calendar-hub
        launchctl bootout gui/$(id -u)/homebrew.mxcl.calendar-sync
        rm ~/Library/LaunchAgents/homebrew.mxcl.calendar-sync.plist
      If "Open at login" was on in Settings, switch it on again.

      The build is ad-hoc signed, so macOS asks for calendar access (and
      Reminders access, once you open Tasks) again after each upgrade. Your
      settings and tasks are kept.
    EOS
  end

  service do
    run opt_prefix/"Calendar Hub.app/Contents/MacOS/CalendarHub"
    process_type :interactive
  end

  test do
    assert_path_exists prefix/"Calendar Hub.app/Contents/MacOS/CalendarHub"
  end
end
