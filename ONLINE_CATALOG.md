# Open music provider integration

Aurora ships with a keyless Internet Archive provider. It searches its
Creative-Commons-tagged `opensource_audio` collection and streams a published
audio file directly from archive.org. This is an open-music discovery source,
not a substitute for a Spotify-scale commercial catalog.

## Provider boundary

The `MusicProvider` interface lets the app use another legitimate source later.
Providers supply search, discovery, and a permitted stream URL. The Flutter
client has no private provider credentials.

For a future commercial provider, obtain its explicit streaming licence and
implement a provider adapter or a self-hosted service that issues authorized,
short-lived URLs. Never put provider secrets in the app or scrape streams from
other music services.
