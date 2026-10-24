# Homebrew formula for Calendar Sync. The source copy lives in the app repository at
# packaging/homebrew/calendar-sync.rb; keep the two in step.
#
# Releasing a new version: point `url` at the new commit (or tag) archive, update `version`
# to match Support/Info.plist, and set `sha256` to the output of
#   curl -L <url> | shasum -a 256
class CalendarSync < Formula
  desc "Menu bar app that copies client-calendar meetings into your main calendar"
  homepage "https://github.com/neteinstein/Calendar-Sync"
  url "https://github.com/neteinstein/Calendar-Sync/archive/71722390add7b710d4146d9ef47f1148b47ee51b.tar.gz"
  version "0.2.0"
  sha256 "43a2e97ada32b47ddc5432217569a542d7aaa5e011c87d5001232cb75d047f65"
  license "PolyForm-Noncommercial-1.0.0"
  head "https://github.com/neteinstein/Calendar-Sync.git", branch: "main"

  depends_on macos: :sonoma

  def install
    # Builds with the system Swift toolchain (Xcode 15+ command line tools are enough)
    # and ad-hoc signs, exactly like a manual source build.
    system "scripts/build-app.sh"
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
