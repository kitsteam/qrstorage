# ADR 0001: Restrict direct access to audio files

- Status: Implemented
- Date: 2026-11-23

## Context

Audio files (recordings and TTS) are served via `GET /audio_file/:id`
(`QrCodeController.audio_file/2`). The route is public and permanent: anyone who
has or guesses the URL can fetch the audio without visiting the QR code page.
The player (`_player.html.heex`) and the TTS "Download" button (`show.html.heex`)
both link to this route.

We want audio to be reachable only through the QR code page, not via a link that
can be shared or bookmarked. Anyone who can open the page can still save the
audio, because the browser has to fetch it to play it. This ADR does not try to
prevent that.

## Decision

Combine two checks on `audio_file/2`:

1. **Short-lived signed token.** The page embeds `?t=<token>` in the audio URL.
   The token is created with `Phoenix.Token.sign/3` (salt `"audio_file"`, payload
   = QR code id) and verified with `max_age` of 1 hour. The token must match the
   id in the route, so it can't be reused for another QR code.
2. **Fetch-metadata check.** Reject requests whose `Sec-Fetch-Dest` is not
   `audio` or `empty` (the player), with one exception: `document` is allowed
   for the TTS Download link, which is a top-level navigation. A missing header
   (older browsers, non-browser clients) falls back to token-only. If
   `Sec-Fetch-Site` is present it must be `same-origin`.

The Download button keeps working by carrying a token too; the `document`
exception only applies when a valid token is present.

Failures return 403 before any database or storage access.

## Changes

- `lib/qrstorage_web/audio_token.ex` (new): `sign/2` and `verify/2`, holding the
  salt and `max_age`.
- `qr_code_controller.ex`: guard at the top of `audio_file/2` (token +
  `Sec-Fetch-*` check, 403 on failure).
- `qr_code_controller.ex`: assign `audio_token` in `show/2` (and `preview/2` if
  it renders the player).
- `_player.html.heex`: `data-url` includes `t: @audio_token`.
- `show.html.heex`: Download link includes `t: @audio_token`.
- Tests (`qr_code_controller_test.exs`): update existing `audio_file` tests to
  send a valid token and `sec-fetch-dest: audio`; add cases for missing, invalid,
  expired and wrong-id tokens, `document` without a token, missing
  `Sec-Fetch-Dest` fallback, and that rendered pages contain `t=`.

No schema, migration, router or config changes (uses the existing
`secret_key_base`).

## Consequences

- Copied audio links stop working after the token expires; links without a
  token never work.
- A player tab left open longer than `max_age` will fail to load audio until
  reloaded. We accept this rather than adding a token-refresh endpoint.
- `Sec-Fetch-*` headers can be spoofed by non-browser clients, so the token is
  the real protection and the header check only blocks casual direct navigation.
- Existing printed QR codes are unaffected: they point to the QR code page, which
  issues a fresh token on every view.

## Alternatives considered

- **Session-bound access only:** breaks in in-app QR scanners that open a
  different webview and lose cookies.
- **Embedding audio in the page (data/Blob URL):** no audio URL at all, but
  larger pages and unreliable seeking on iOS Safari.
- **Removing the Download button:** stricter, but removes an existing feature.
