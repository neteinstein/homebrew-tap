class MacosDnsChanger < Formula
  desc "Menu bar app that turns on encrypted DNS (DNS over TLS) with one click"
  homepage "https://github.com/neteinstein/MacOS-MenuBar-DNS-Changer"
  url "https://github.com/neteinstein/MacOS-MenuBar-DNS-Changer/archive/544cedd85a814835406e1f26e068d823b31a7e8b.tar.gz"
  version "0.1.0"
  sha256 "91dff7eb60850523ba68aade934e1408f7a7b82c70a209c218ffbf221acb158b"
  head "https://github.com/neteinstein/MacOS-MenuBar-DNS-Changer.git", branch: "main"

  depends_on macos: :ventura

  def install
    # Builds with the system Swift toolchain (Xcode 15+ command line tools are enough)
    # and ad-hoc signs, exactly like a manual source build. SwiftPM's own sandbox can't
    # nest inside Homebrew's build sandbox ("sandbox_apply: Operation not permitted").
    system "scripts/build-app.sh", "--disable-sandbox"
    prefix.install "build/Private DNS.app"
  end

  def caveats
    <<~EOS
      Private DNS is a menu bar app. To start it once:
        open "#{opt_prefix}/Private DNS.app"

      To start it at every login, use brew services (below) rather than
      "Open at login" in the app's Settings. The service runs the app from
      #{opt_prefix}, which keeps pointing at the newest version
      after brew upgrade.

      This build is ad-hoc signed, so it switches DNS with configuration
      profiles: after each switch, install the profile in System Settings ›
      Privacy & Security › Profiles (or General › Device Management).
      One-click switching needs a build signed with Apple's Network Extension
      entitlement; see the README.

      brew upgrade doesn't restart a running copy. If you started it with
      brew services:
        brew services restart macos-dns-changer
      If you opened it yourself, quit it from its menu and open it again.

      If Homebrew refuses to load the formula from an untrusted tap, run:
        brew trust --formula neteinstein/tap/macos-dns-changer
    EOS
  end

  service do
    run opt_prefix/"Private DNS.app/Contents/MacOS/PrivateDNSMenuBar"
    process_type :interactive
  end

  test do
    assert_path_exists prefix/"Private DNS.app/Contents/MacOS/PrivateDNSMenuBar"
  end
end
