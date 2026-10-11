<#
.SYNOPSIS
Captures the three Spanish Android Play Store screenshots from a local device.

.DESCRIPTION
Runs the existing Flutter integration driver against one attached Android target.
Output is always the canonical project directory:
fastlane/metadata/android/es-419/images/phoneScreenshots

The script never accepts a custom output directory and never performs authentication,
uploads, release builds, or signing changes.

.PARAMETER Device
Required Flutter Android device ID from `flutter devices`.

.PARAMETER Force
Permits replacing only the three expected PNGs when the canonical output directory
is nonempty. Each existing target is validated before any file is removed.

.PARAMETER Help
Shows this help text without requiring Flutter or a device.

.EXAMPLE
powershell -NoProfile -ExecutionPolicy Bypass -File .\tool\capture_android_play_screenshots.ps1 -Device R58N123ABC
#>
[CmdletBinding()]
param(
    [Parameter()]
    [string]$Device,

    [switch]$Force,

    [switch]$Help
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ExpectedScreenshots = @(
    '01-welcome.png',
    '02-onboarding.png',
    '03-budget-setup-choice.png'
)

function Show-Usage {
    @'
Usage:
  capture_android_play_screenshots.ps1 -Device <id> [-Force]

Captures the three Spanish (es-419) Android phone screenshots locally with
Flutter's integration test driver. Output is always written to:
  fastlane/metadata/android/es-419/images/phoneScreenshots

No authentication, upload, release build, or signing configuration is used.

Parameters:
  -Device <id>  Required Android device ID from `flutter devices`.
  -Force        Permit replacing the three expected PNG files in a nonempty
                output directory. Other files are never deleted or replaced.
  -Help         Show this help text.
'@ | Write-Output
}

function Fail {
    param([Parameter(Mandatory = $true)][string]$Message)

    throw "ERROR: $Message"
}

function Test-ReparsePoint {
    param([Parameter(Mandatory = $true)][System.IO.FileSystemInfo]$Item)

    return ($Item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

if ($Help) {
    Show-Usage
    exit 0
}

if ([string]::IsNullOrWhiteSpace($Device)) {
    Fail 'Missing required -Device <id>. Run `flutter devices` to find it.'
}

if ($Device -notmatch '^[A-Za-z0-9._:-]+$') {
    Fail 'Device IDs may contain only letters, numbers, dots, underscores, colons, and hyphens.'
}

$flutterCommand = Get-Command flutter -CommandType Application -ErrorAction SilentlyContinue
if ($null -eq $flutterCommand) {
    Fail 'Flutter was not found on PATH. Install Flutter or add its bin directory to PATH, then rerun.'
}

$scriptDirectory = Split-Path -Parent $MyInvocation.MyCommand.Path
$projectDirectory = (Resolve-Path -LiteralPath (Join-Path $scriptDirectory '..')).Path
$testFile = Join-Path $projectDirectory 'integration_test/play_store_screenshots_test.dart'
$driverFile = Join-Path $projectDirectory 'integration_test/play_store_screenshot_driver.dart'
$canonicalOutputDirectory = Join-Path $projectDirectory 'fastlane/metadata/android/es-419/images/phoneScreenshots'

foreach ($requiredFile in @($testFile, $driverFile)) {
    if (-not (Test-Path -LiteralPath $requiredFile -PathType Leaf)) {
        Fail "Required Dart integration file is missing: $requiredFile"
    }
}

try {
    $flutterDevicesJson = & $flutterCommand.Source devices --machine
    if ($LASTEXITCODE -ne 0) {
        Fail 'Unable to query Flutter devices. Run `flutter devices` to diagnose the local Flutter installation.'
    }
    $flutterDevices = ($flutterDevicesJson -join [Environment]::NewLine) | ConvertFrom-Json
}
catch {
    if ($_.Exception.Message -like 'ERROR:*') {
        throw
    }
    Fail 'Flutter did not return valid device JSON. Run `flutter devices --machine` to diagnose the local Flutter installation.'
}

$matchingAndroidDevices = @(
    $flutterDevices | Where-Object {
        $null -ne $_ -and
        ([string]$_.id -eq $Device) -and
        $null -ne $_.targetPlatform -and
        ([string]$_.targetPlatform).StartsWith('android', [System.StringComparison]::OrdinalIgnoreCase)
    }
)
if ($matchingAndroidDevices.Count -eq 0) {
    Fail "No attached Android Flutter target matches device ID '$Device'. Run `flutter devices` and pass an Android device ID."
}

# Check the project root and every existing output ancestor before creating any
# directory. A junction or symlink could otherwise redirect captures outside it.
$projectDirectoryItem = Get-Item -LiteralPath $projectDirectory -Force
if (-not ($projectDirectoryItem -is [System.IO.DirectoryInfo]) -or (Test-ReparsePoint $projectDirectoryItem)) {
    Fail "Project directory must be a non-reparse directory: $projectDirectory"
}

$outputPathComponents = @('fastlane', 'metadata', 'android', 'es-419', 'images', 'phoneScreenshots')
$currentOutputAncestor = $projectDirectory
foreach ($pathComponent in $outputPathComponents) {
    $currentOutputAncestor = Join-Path $currentOutputAncestor $pathComponent
    $ancestorItem = Get-Item -LiteralPath $currentOutputAncestor -Force -ErrorAction SilentlyContinue
    if ($null -eq $ancestorItem) {
        continue
    }
    if (-not ($ancestorItem -is [System.IO.DirectoryInfo]) -or (Test-ReparsePoint $ancestorItem)) {
        Fail "Screenshot output path contains a non-directory or reparse point: $currentOutputAncestor"
    }
}

New-Item -ItemType Directory -Force -Path $canonicalOutputDirectory | Out-Null
$outputDirectoryItem = Get-Item -LiteralPath $canonicalOutputDirectory -Force
if (-not ($outputDirectoryItem -is [System.IO.DirectoryInfo]) -or (Test-ReparsePoint $outputDirectoryItem)) {
    Fail "Screenshot output must be the canonical non-reparse directory: $canonicalOutputDirectory"
}

$targetPaths = @($ExpectedScreenshots | ForEach-Object { Join-Path $canonicalOutputDirectory $_ })
$hasOutput = @(
    Get-ChildItem -LiteralPath $canonicalOutputDirectory -Force | Select-Object -First 1
).Count -gt 0
if ($hasOutput -and -not $Force) {
    Fail "Screenshot directory is not empty: $canonicalOutputDirectory. Re-run with -Force to replace only the expected PNGs."
}

if ($Force) {
    # Validate every target before deleting anything so stale files cannot satisfy
    # post-capture verification when Flutter fails to produce a replacement.
    $existingTargets = @()
    foreach ($targetPath in $targetPaths) {
        $targetItem = Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
        if ($null -ne $targetItem) {
            if ((Test-ReparsePoint $targetItem) -or -not ($targetItem -is [System.IO.FileInfo])) {
                Fail "Expected screenshot path is not a regular non-reparse file: $targetPath"
            }
            $existingTargets += $targetItem
        }
    }

    foreach ($targetItem in $existingTargets) {
        Remove-Item -LiteralPath $targetItem.FullName -Force
    }
}

foreach ($targetPath in $targetPaths) {
    if (Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue) {
        Fail "Expected screenshot path already exists before capture: $targetPath"
    }
}

Write-Output "Capturing Play Store screenshots to: $canonicalOutputDirectory"
Write-Output "Expected files: $($ExpectedScreenshots -join ', ')"

$hadPreviousScreenshotOutput = Test-Path Env:PLAY_STORE_SCREENSHOT_OUTPUT
$previousScreenshotOutput = $env:PLAY_STORE_SCREENSHOT_OUTPUT
try {
    # This variable is set immediately before flutter drive and restored in finally.
    $env:PLAY_STORE_SCREENSHOT_OUTPUT = $canonicalOutputDirectory
    Push-Location $projectDirectory
    try {
        & $flutterCommand.Source drive `
            --driver='integration_test/play_store_screenshot_driver.dart' `
            --target='integration_test/play_store_screenshots_test.dart' `
            "--device-id=$Device"
        if ($LASTEXITCODE -ne 0) {
            Fail 'Flutter screenshot capture failed. See the Flutter output above for details.'
        }
    }
    finally {
        Pop-Location
    }
}
finally {
    if ($hadPreviousScreenshotOutput) {
        $env:PLAY_STORE_SCREENSHOT_OUTPUT = $previousScreenshotOutput
    }
    else {
        Remove-Item Env:PLAY_STORE_SCREENSHOT_OUTPUT -ErrorAction SilentlyContinue
    }
}

foreach ($targetPath in $targetPaths) {
    $screenshotItem = Get-Item -LiteralPath $targetPath -Force -ErrorAction SilentlyContinue
    if ($null -eq $screenshotItem -or (Test-ReparsePoint $screenshotItem) -or -not ($screenshotItem -is [System.IO.FileInfo]) -or $screenshotItem.Length -le 0) {
        Fail "Capture did not produce a newly created non-empty regular screenshot: $targetPath"
    }
}

Write-Output "Capture complete. Fastlane-compatible screenshots are in: $canonicalOutputDirectory"
