# Audio Conversion Script for Zero-Latency Keyboard Sounds
# Converts MP3 to optimized WAV format (Mono, 48kHz, 16-bit PCM)

Write-Host "=== Audio Conversion for Keyote ===" -ForegroundColor Cyan
Write-Host ""

# Check if ffmpeg is installed
try {
    $ffmpegVersion = ffmpeg -version 2>&1 | Select-Object -First 1
    Write-Host "[OK] FFmpeg found: $ffmpegVersion" -ForegroundColor Green
} catch {
    Write-Host "[ERROR] FFmpeg not found!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Please install FFmpeg first:" -ForegroundColor Yellow
    Write-Host "1. Download from: https://ffmpeg.org/download.html" -ForegroundColor White
    Write-Host "2. Or use winget: winget install FFmpeg" -ForegroundColor White
    Write-Host "3. Or use chocolatey: choco install ffmpeg" -ForegroundColor White
    exit 1
}

Write-Host ""

# Get all MP3 files in current directory
$mp3Files = Get-ChildItem -Path . -Filter "*.mp3"

if ($mp3Files.Count -eq 0) {
    Write-Host "No MP3 files found in current directory" -ForegroundColor Yellow
    exit 0
}

Write-Host "Found $($mp3Files.Count) MP3 file(s) to convert:" -ForegroundColor Cyan
$mp3Files | ForEach-Object { Write-Host "  - $($_.Name)" -ForegroundColor White }
Write-Host ""

# Convert each MP3 to optimized WAV
foreach ($mp3 in $mp3Files) {
    $inputFile = $mp3.Name
    $outputFile = $mp3.BaseName + ".wav"
    
    Write-Host "Converting: $inputFile -> $outputFile" -ForegroundColor Yellow
    
    # FFmpeg command for optimal keyboard sound:
    # -ac 1: Mono (half RAM, faster load)
    # -ar 48000: 48kHz sample rate (Android native, no resampling)
    # -sample_fmt s16: 16-bit PCM (raw data, instant playback)
    # -y: Overwrite if exists
    
    ffmpeg -i $inputFile -ac 1 -ar 48000 -sample_fmt s16 -y $outputFile 2>&1 | Out-Null
    
    if ($LASTEXITCODE -eq 0) {
        $originalSize = [math]::Round($mp3.Length / 1KB, 2)
        $newSize = [math]::Round((Get-Item $outputFile).Length / 1KB, 2)
        Write-Host "  [OK] Success! ($originalSize KB -> $newSize KB)" -ForegroundColor Green
    } else {
        Write-Host "  [FAIL] Failed to convert $inputFile" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Conversion Complete ===" -ForegroundColor Cyan
Write-Host ""
Write-Host "Next steps:" -ForegroundColor Yellow
Write-Host "1. Update constants.dart to use .wav extensions" -ForegroundColor White
Write-Host "2. Update pubspec.yaml to reference .wav files" -ForegroundColor White
Write-Host "3. Delete old .mp3 files (optional)" -ForegroundColor White
Write-Host "4. Run flutter pub get to refresh assets" -ForegroundColor White
Write-Host ""
