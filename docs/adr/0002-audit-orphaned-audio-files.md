# 0002. Audit audio files in object storage for missing qr codes

- Status: Accepted
- Date: 2026-11-25

## Context

Recordings and TTS files are stored under `audio/recording/<qr_id>.webm` and
`audio/tts/<qr_id>.mp3`; the qr codes live in the `qrcodes` table. Every audio
file should have an existing qr code, but nothing verifies this. Orphans can
appear when `delete_all_objects` fails after the row was deleted (the comment in
`StorageService` already says such files need manual cleanup), or when an upload
succeeds and a following DB step fails.

Audio is encrypted user content and, per
[0001](0001-restrict-direct-audio-file-access.md), shielded from direct access.
Orphans are data we should not keep, so we need to find them. The result must
only be logged or otherwise not publicly reachable.

Facts: the qr code id is part of every object key. `ObjectStorageService` had no
list operation. The qr code row is created before the upload and deleted before
the file, so a file can briefly look orphaned.

## Decision

We will add a read-only audit that runs weekly as an Oban cron job
(`Qrstorage.Worker.AuditAudioStorageWorker`, Thursday 12:00 UTC, own `audit`
queue so it can't block `RemoveCodesWorker`) and can also be run on demand as a
release task: `bin/qrstorage eval "Qrstorage.Release.audit_audio_storage()"`.

- It lists all objects under `audio/` (new `ObjectStorageService.list_objects/2`,
  paginated via `ExAws.stream!/1`) and looks the ids up in the DB in batches of
  500 (`Qrstorage.Services.StorageAudit`).
- A file is an orphan if no qr code has its id, or if the qr code's content type
  doesn't match the folder (`recording` -> `:recording`, `tts` -> `:audio`).
  Keys not matching `audio/<type>/<uuid>.<ext>` are reported as unrecognized.
- Files younger than a grace period (default 60 min) are skipped and counted.
- The worker logs the report (`warning` if there are orphans or unrecognized
  keys, `info` otherwise) and returns an error if the listing fails, so Oban
  retries. The release task prints it to stdout. Nothing is deleted.
- The release task starts only `hackney`, `ex_aws` and the repo, not the
  endpoint or Oban, so it can run next to the live app.

## Alternatives considered

- **Admin route with Basic Auth:** convenient for ad-hoc checks, but adds an
  authenticated HTTP endpoint on an app that serves user content and needs
  credential management. Can be built on `StorageAudit` later.
- **DB-driven set diff on startup:** would also find qr codes with missing files
  and needs no auth, but adds a bucket listing and DB load to every deploy, and
  memory grows with the number of codes.
- **Release task only (manual):** the first version, but drift is only noticed
  when someone remembers to run it.
- **Bucket lifecycle policy or external script (`aws s3 ls` + `comm` on a DB
  dump):** lifecycle rules can't see the database, and a script duplicates the
  key and type logic outside the code base and needs DB access from outside.

## Consequences

- Good: no new HTTP surface, consistent with 0001.
- Good: memory stays flat regardless of bucket size; one DB query per 500 files.
- Good: the listing sits behind the Mox-mockable service behaviour, and
  `StorageAudit` is reusable for a route or cron job later.
- Bad: orphans are only noticed if someone reads the weekly log or alerts on
  the warning, and up to a week after they appear.
- Bad: the weekly bucket listing and DB lookups add some load on Thursdays.
- Bad: cleanup stays manual; the report lists keys only.
- Bad: expired qr codes not yet removed by `RemoveCodesWorker` still count as
  existing, so their files are not reported.
