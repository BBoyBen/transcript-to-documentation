---
name: video-screenshot
description: >-
  Extracts screenshots from KT video recordings at specific timecodes and inserts
  AI-generated screen descriptions as visual callout blocks in cleaned transcripts.
  Use when enriching transcripts that contain timecodes ([HH:MM:SS] or [MM:SS]),
  when asked to describe what is shown on screen during a knowledge transfer session,
  or when adding visual annotations to a transcript section. Requires FFmpeg in PATH.
---

# Video Screenshot

Enrich cleaned transcript files with visual context by extracting screenshots from the corresponding KT video at specific timecodes, then inserting AI-generated screen descriptions directly into the transcript content.

## When to Use This Skill

- Cleaning a transcript that contains timecodes
- Asked to add visual context to a transcript section
- Explicitly requested to describe screen content at a specific point during a KT

## Available Scripts

| Script | Purpose |
|--------|---------|
| [`scripts/extract-frame.ps1`](./scripts/extract-frame.ps1) | Resolve video path, extract screenshot(s) at a timecode via FFmpeg, output file path(s) |

---

## Prerequisites

- **FFmpeg** must be installed and available in the system PATH (`ffmpeg -version` should succeed)
- The video file must exist at the path resolved by the naming convention below
- The `temp/screenshots/` folder must be accessible at the workspace root (created automatically by the script if missing)

---

## Video File Convention

Videos follow the same naming and folder structure as their source transcripts, stored under `videos/` at the workspace root:

| Transcript path | Video path |
|---|---|
| `transcripts/raw/domain1/KT_1.transcript` | `videos/domain1/KT_1.mp4` |
| `transcripts/raw/domain2/KT_5.transcript` | `videos/domain2/KT_5.mp4` |

Supported video extensions (try in order): `.mp4`, `.mkv`, `.avi`, `.mov`, `.webm`

---

## Timecode Format

Timecodes in transcripts follow one of these patterns:

| Pattern | Example | Notes |
|---|---|---|
| `[HH:MM:SS]` | `[00:12:45]` | Standard bracketed |
| `[MM:SS]` | `[12:45]` | Short — prepend `00:` for FFmpeg |
| `HH:MM:SS` | `00:12:45` | Bare long |
| `MM:SS` | `12:45` | Bare short — prepend `00:` for FFmpeg |

Regex to detect timecodes in transcript text: `\[?\d{1,2}:\d{2}(:\d{2})?\]?`

---

## Workflow

### Step 1 — Resolve the video path

Pass `-TranscriptName` and `-Domain` to [`scripts/extract-frame.ps1`](./scripts/extract-frame.ps1); it resolves the path automatically.
If the script exits with code 1 and logs `⚠️ No video found`, skip visual enrichment for this file entirely.

### Step 2 — Extract the screenshot(s)

For each timecode, run [`scripts/extract-frame.ps1`](./scripts/extract-frame.ps1):

**Single-frame** (default — one precise frame):

```powershell
.\extract-frame.ps1 -TranscriptName <base_name> -Timecode <timecode> -Domain <domain>
# Returns: temp\screenshots\screenshot_<base_name>_<timecode_safe>.jpg
```

**Multi-frame** (optional — 3 frames over 10 s around the timecode, for fast-moving demos):

```powershell
.\extract-frame.ps1 -TranscriptName <base_name> -Timecode <timecode> -Domain <domain> -MultiFrame
# Returns: temp\screenshots\screenshot_<base_name>_<timecode_safe>_01.jpg (+ _02, _03)
```

The script handles: video path resolution across multiple extensions, timecode normalisation (strips brackets, pads `MM:SS` to `HH:MM:SS`), output folder creation, and FFmpeg error reporting. It exits with code 1 and a `⚠️` warning on any failure.

### Step 3 — Describe the screenshot via sub-agent

Do **not** call `view_image` directly. Use `#runSubagent describe-screenshot` so that vision
analysis runs in a dedicated GPT context with the `view_image` tool available.

> **One invocation per screenshot.** If `extract-frame.ps1` returned multiple frames (multi-frame
> mode), invoke `describe-screenshot` once per frame — do not bundle multiple paths in a single
> call. This keeps each sub-agent context small and prevents response truncation.

Invocation prompt template (repeat for each frame):

```
Describe the screenshot extracted from this KT session.

screenshot_path: <single path returned by extract-frame.ps1>
timecode: <HH:MM:SS>
transcript_context: "<the sentence or two from the transcript at this timecode>"
```

The sub-agent analyses the image, writes its `.description.md`, then signals completion.
Wait for each invocation to finish before launching the next.

### Step 4 — Read back the description

After `describe-screenshot` completes, read the companion `.description.md` file:

```
temp/screenshots/screenshot_<base_name>_<timecode_safe>.description.md
```

Extract the body text (everything after the `---` metadata lines) to use as the callout content.
If the file is missing or contains a `⚠️` prefix, skip this timecode and log the warning.

### Step 5 — Insert the visual annotation

Insert the visual annotation into the clean transcript immediately **after** the sentence or paragraph containing the corresponding timecode.

Use this callout block format:

```markdown
> **[Visual — HH:MM:SS]** Description of what is visible on screen.
```

**Placement rules**:

- Insert after the complete sentence/paragraph that references the timecode, not in the middle of it
- Use a blank line before and after the callout block
- If the timecode appears inside a bullet list item, place the callout after the entire list block
- Never replace existing transcript content — the annotation is always additive

### Step 6 — Cleanup

After successful insertion, delete the temporary screenshot and description file(s) from `temp/screenshots/`:

```powershell
Remove-Item "temp\screenshots\screenshot_${TranscriptName}_*.jpg" -ErrorAction SilentlyContinue
Remove-Item "temp\screenshots\screenshot_${TranscriptName}_*.description.md" -ErrorAction SilentlyContinue
```

---

## Full Example

**Input — raw transcript excerpt**:

```
[00:12:45] So here I'm opening the configuration panel - you can see there's a connection string field that I need to fill in for the SQL database.
```

**Step 2 — extract-frame.ps1 call**:

```powershell
.\extract-frame.ps1 -TranscriptName KT_1 -Timecode 00:12:45 -Domain domain1
# Returns: temp\screenshots\screenshot_KT_1_00-12-45.jpg
```

**Step 3 — Sub-agent invocation**:

```
Describe the screenshot(s) extracted from this KT session.

screenshot_path: temp/screenshots/screenshot_KT_1_00-12-45.jpg
timecode: 00:12:45
transcript_context: "So here I'm opening the configuration panel - you can see there's a connection string field that I need to fill in for the SQL database."
```

`describe-screenshot` writes `temp/screenshots/screenshot_KT_1_00-12-45.description.md`:

```markdown
# Screenshot Description

**Timecode**: 00:12:45
**Source**: screenshot_KT_1_00-12-45.jpg

The screen shows Visual Studio Code with `appsettings.json` open in the editor. The JSON file
contains a highlighted `ConnectionStrings` section where a SQL Server connection string is being
typed. A debug terminal at the bottom shows the ASP.NET Core application running and waiting
for configuration.
```

**Step 4 — Read back**:

The main agent reads `temp/screenshots/screenshot_KT_1_00-12-45.description.md` and extracts the description body.

**Step 5 — Resulting clean transcript section**:

```markdown
### Configuration Setup

[00:12:45] The presenter opens the configuration panel to configure the SQL database connection string.

> **[Visual — 00:12:45]** The screen shows Visual Studio Code with `appsettings.json` open in the editor.
> The JSON file contains a highlighted `ConnectionStrings` section where a SQL Server connection string
> is being typed. A debug terminal at the bottom shows the ASP.NET Core application running and waiting
> for configuration.
```

---

## Integration with `clean-transcript`

When `clean-transcript` processes a transcript file:

1. After structuring and cleaning the content, scan the entire text for timecodes (regex: `\[?\d{1,2}:\d{2}(:\d{2})?\]?`)
2. For each unique timecode found, invoke this skill
3. Insert all visual annotations before finalizing the output file

> **Note**: Visual enrichment is **additive and optional**. If FFmpeg is unavailable or the video is missing,
> `clean-transcript` must still produce a complete, valid output. Never block the cleaning phase on video availability.

---

## Error Handling

| Situation | Action |
|---|---|
| Video file not found | Log `⚠️ No video found for <transcript_name>` — skip all visual enrichment for this file |
| FFmpeg not installed | Log `⚠️ FFmpeg unavailable — visual enrichment skipped` — skip all visual enrichment |
| Frame extraction fails (FFmpeg error) | Log `⚠️ Frame extraction failed at <timecode>` — skip this timecode only |
| `view_image` returns empty or fails | Log `⚠️ No description generated at <timecode>` — skip this timecode only |
| `temp/screenshots/` folder missing | Created automatically by the script before running FFmpeg |
| Video found but timecode out of range | FFmpeg will produce a black frame — include description noting "end of recording reached" |
