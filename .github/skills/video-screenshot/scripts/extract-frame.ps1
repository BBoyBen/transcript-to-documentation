<#
.SYNOPSIS
    Extracts a screenshot frame from a KT video recording at a specified timecode.

.DESCRIPTION
    Resolves the video file that matches a transcript base name (same folder structure
    under `videos/`), then runs FFmpeg to extract one or more frames at the given
    timecode. Saves the result(s) to the output folder and writes the resulting
    file path(s) to stdout for the calling agent to consume.

    Supported timecode formats: HH:MM:SS, MM:SS, [HH:MM:SS], [MM:SS]
    Supported video extensions (tried in order): .mp4, .mkv, .avi, .mov, .webm

.PARAMETER TranscriptName
    Base name of the transcript without extension, e.g. "KT_1".

.PARAMETER Timecode
    Timecode where the frame should be extracted, e.g. "00:12:45" or "12:45".
    Surrounding brackets are stripped automatically.

.PARAMETER Domain
    Domain subfolder under VideosRoot. Omit for a flat video folder structure.

.PARAMETER VideosRoot
    Root folder containing domain-structured videos. Default: "videos".

.PARAMETER OutputFolder
    Folder where screenshots are saved. Created if it does not exist. Default: "temp".

.PARAMETER MultiFrame
    When set, extract 3 frames over a 10-second window centred on the timecode
    instead of a single precise frame. Use for fast-moving demos.

.EXAMPLE
    .\extract-frame.ps1 -TranscriptName KT_1 -Timecode 00:12:45 -Domain domain1
    # Output: temp\screenshots\screenshot_KT_1_00-12-45.jpg

.EXAMPLE
    .\extract-frame.ps1 -TranscriptName KT_1 -Timecode "[12:45]" -Domain domain1 -MultiFrame
    # Output: temp\screenshots\screenshot_KT_1_00-12-45_01.jpg  (+ _02.jpg, _03.jpg)

.OUTPUTS
    String — absolute or relative path(s) of the extracted screenshot file(s).
    Exits with code 1 and a warning message on any recoverable error.
#>

[CmdletBinding()]
param(
    [Parameter(Mandatory)][string] $TranscriptName,
    [Parameter(Mandatory)][string] $Timecode,
    [string] $Domain       = "",
    [string] $VideosRoot   = "videos",
    [string] $OutputFolder = "temp/screenshots",
    [switch] $MultiFrame
)

Set-StrictMode -Version Latest
$ErrorActionPreference = "Stop"

# ── 1. Verify FFmpeg is available ────────────────────────────────────────────
if (-not (Get-Command ffmpeg -ErrorAction SilentlyContinue)) {
    Write-Warning "FFmpeg unavailable — visual enrichment skipped"
    exit 1
}

# ── 2. Normalise timecode to HH:MM:SS ────────────────────────────────────────
$TimecodeClean = $Timecode -replace '[\[\]]', ''        # strip brackets
if ($TimecodeClean -match '^\d{1,2}:\d{2}$') {
    $TimecodeClean = "00:$TimecodeClean"                # MM:SS → HH:MM:SS
}
$TimecodeSafe = $TimecodeClean -replace ':', '-'        # used in filenames

# ── 3. Resolve video path ─────────────────────────────────────────────────────
$extensions   = @('.mp4', '.mkv', '.avi', '.mov', '.webm')
$searchFolder = if ($Domain) { Join-Path $VideosRoot $Domain } else { $VideosRoot }
$videoPath    = $null

foreach ($ext in $extensions) {
    $candidate = Join-Path $searchFolder "$TranscriptName$ext"
    if (Test-Path $candidate) {
        $videoPath = $candidate
        break
    }
}

if (-not $videoPath) {
    Write-Warning "No video found for '$TranscriptName' in '$searchFolder'"
    exit 1
}

# ── 4. Ensure output folder exists (creates parents too, idempotent) ──────────
New-Item -ItemType Directory -Path $OutputFolder -Force | Out-Null

# ── 5. Extract frame(s) ──────────────────────────────────────────────────────
if ($MultiFrame) {
    # Compute start offset (5 s before the timecode, clamped to 0)
    $parts        = $TimecodeClean -split ':'
    $totalSeconds = [int]$parts[0] * 3600 + [int]$parts[1] * 60 + [int]$parts[2]
    $startSeconds = [Math]::Max(0, $totalSeconds - 5)

    $outputPattern = Join-Path $OutputFolder "screenshot_${TranscriptName}_${TimecodeSafe}_%02d.jpg"

    & ffmpeg -ss $startSeconds -i $videoPath -t 10 -vf "fps=0.3" -q:v 2 $outputPattern -y 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "FFmpeg failed for '$TranscriptName' at '$Timecode' (multi-frame)"
        exit 1
    }

    # Return paths of all produced frames
    Get-ChildItem -Path $OutputFolder -Filter "screenshot_${TranscriptName}_${TimecodeSafe}_*.jpg" |
        Select-Object -ExpandProperty FullName

} else {
    $outputFile = Join-Path $OutputFolder "screenshot_${TranscriptName}_${TimecodeSafe}.jpg"

    & ffmpeg -ss $TimecodeClean -i $videoPath -vframes 1 -q:v 2 $outputFile -y 2>&1 | Out-Null
    if ($LASTEXITCODE -ne 0) {
        Write-Warning "FFmpeg failed for '$TranscriptName' at '$Timecode'"
        exit 1
    }

    Write-Output $outputFile
}
