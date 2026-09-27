# Aurora

Aurora is a private Android music player built with Flutter. It plays device audio and streams a keyless open-music source; it has no advertising, commercial-catalog integration, or required account.

## Features

- Internet Archive Creative-Commons-tagged open-audio search and streaming, with no API key
- Android MediaStore scanning with runtime audio permission handling
- Background playback, media notification, Bluetooth/lock-screen transport controls
- Persistent favorites, recent history, and locally stored playlists
- Search across local titles, artists, and albums
- A focused dark, premium original interface with Home, Search, Library, Settings, mini-player, and Now Playing surfaces

## Run

Install Flutter, connect an Android device, then run:

```sh
flutter pub get
flutter run
```

No audio is bundled with the app. Open-music availability depends on the Internet Archive connection; local audio remains available when offline.
