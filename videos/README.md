# KT Videos

This folder stores video recordings of Knowledge Transfer sessions.
These videos are used by the `clean-transcript` agent (via the `video-screenshot` skill)
to extract screenshots at specific timecodes and enrich the cleaned transcripts with visual context.

## Folder Structure

Videos must follow **the same naming and folder hierarchy** as the source transcripts under `transcripts/raw/`:

```
videos/
├── domain1/
│   ├── KT_1.mp4
│   └── KT_2.mp4
└── domain2/
    └── KT_5.mp4
```

## Naming Convention

| Source transcript | Expected video file |
|---|---|
| `transcripts/raw/domain1/KT_1.transcript` | `videos/domain1/KT_1.mp4` |
| `transcripts/raw/domain2/KT_5.transcript` | `videos/domain2/KT_5.mp4` |

The base name (without extension) must match exactly.

## Supported Formats

`.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`

## Notes

- Videos are **optional** — the pipeline runs without them, but visual enrichment will be skipped.
- FFmpeg must be installed for frame extraction. Verify with `ffmpeg -version`.
- Extracted screenshots are temporary and stored in `temp/` during processing, then deleted automatically.
