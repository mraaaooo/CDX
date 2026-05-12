# Recordings and CDR

## Recording Principles

- Decide whether recordings are call-control artifacts, app playback artifacts, or compliance archives.
- Keep recording files outside Git-managed deployment trees.
- Preserve a stable key from app call row to FreeSWITCH recording, usually UUID.
- Do not delete source recordings until retention policy is approved and monitored.
- Keep hangup hooks fast and bounded; move copy/upload/transcode work to retryable workers.

## `record_session`

`record_session` is a media-tap dialplan app. In v1.10.12:

- app entry is in `src/mod/applications/mod_dptools/mod_dptools.c`
- recording implementation is in `src/switch_ivr_async.c`
- stop/pause/resume/mask support is also in `mod_dptools` and `switch_ivr_async`

Useful variables and behaviors to verify in source for the running version:

- `RECORD_STEREO`
- `RECORD_STEREO_SWAP`
- `RECORD_READ_ONLY`
- `RECORD_WRITE_ONLY`
- `RECORD_APPEND`
- `RECORD_ANSWER_REQ`
- `RECORD_BRIDGE_REQ`
- `RECORD_MIN_SEC`
- `RECORD_INITIAL_TIMEOUT_MS`
- `RECORD_FINAL_TIMEOUT_MS`
- `RECORD_SILENCE_THRESHOLD`
- `record_sample_rate`
- `execute_on_record_stop`
- `api_on_record_stop`
- `recording_follow_transfer`

`RECORD_STOP` events include recording metadata such as file path and completion cause in modern versions; verify event headers in `switch_ivr_async.c`.

## Post-Processing

Avoid unbounded shell scripts in hangup or record-stop paths. When post-processing is required:

- validate UUID and path
- enforce path stays under the recording root
- use `timeout`
- log structured success/failure
- never delete the source file in the first phase
- use atomic move/copy for app-visible storage
- make transfer retryable outside the call thread

## CDR Options

Common modules:

- `mod_cdr_csv`: simple CSV files; leg behavior depends on `legs` config and source logic.
- `mod_json_cdr`: JSON to disk and/or HTTP; can log B-legs and post to configured URLs.
- `mod_xml_cdr`: XML CDR output.

For v1.10.12:

- CSV leg filtering and rotate API: `src/mod/event_handlers/mod_cdr_csv/mod_cdr_csv.c`
- JSON CDR URL/file behavior and B-leg logging: `src/mod/event_handlers/mod_json_cdr/mod_json_cdr.c`

Operational commands:

```bash
fs_cli -x 'module_exists mod_cdr_csv'
fs_cli -x 'module_exists mod_json_cdr'
fs_cli -x 'cdr_csv rotate'
```

## Fortrexs Recording Pattern

For FreeSWITCH RU and Dotochki:

- FreeSWITCH records locally, typically under `/var/lib/freeswitch/recordings/YYYYMM/`.
- Filename should include or end with the UUID that Dotochki stores.
- FreeSWITCH finalizer should call app completion callback and validate the closed file.
- Dotochki-side pull/sync should copy closed files into app playback storage.
- App playback path should be exposed through a symlink or mount only after ownership and retention are approved.

Do not make the FreeSWITCH hangup hook responsible for cross-host transfer in the first safe implementation.
