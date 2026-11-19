# homebrew-tap

Homebrew formulas for [neteinstein](https://github.com/neteinstein)'s projects.

## [Calendar Hub](https://github.com/neteinstein/Calendar-Hub)

A tiny macOS menu bar app that copies meetings from your client calendars into your main
calendar. The formula builds it from source on your Mac (needs macOS 14+ and the Xcode 15+
command line tools).

```bash
brew install neteinstein/tap/calendar-hub
open "$(brew --prefix)/opt/calendar-hub/Calendar Hub.app"
```

`brew install --HEAD neteinstein/tap/calendar-hub` builds the latest `main` instead of the
pinned version. Update with `brew update && brew upgrade calendar-hub`.

Calendar Hub was called Calendar Sync (formula `calendar-sync`) up to 2.0.19. `brew update` picks up the rename and `brew upgrade` moves an existing install across.

## [Private DNS](https://github.com/neteinstein/MacOS-MenuBar-DNS-Changer)

A macOS menu bar app that turns on encrypted DNS (DNS over TLS) with a provider you choose, in one
click: Cloudflare, Quad9, Mullvad, NextDNS and more. The formula builds it from source on your Mac
(needs macOS 13+ and the Xcode 15+ command line tools).

```bash
brew install neteinstein/tap/macos-dns-changer
open "$(brew --prefix)/opt/macos-dns-changer/Private DNS.app"
```

`brew install --HEAD neteinstein/tap/macos-dns-changer` builds the latest `main` instead of the
pinned version. Update with `brew update && brew upgrade macos-dns-changer`.
