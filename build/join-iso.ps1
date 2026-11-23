<#
.SYNOPSIS
    Reassembles split PalexusOS ISO parts (*.iso.001, *.iso.002, ...) on Windows.

.DESCRIPTION
    GitHub Releases split ISO files exceeding 2 GiB into numbered parts.
    This script concatenates them using high-speed streaming and verifies
    the resulting ISO's SHA256 hash.

.EXAMPLE
    .\build\join-iso.ps1
    .\build\join-iso.ps1 -Directory C:\Users\Earn\Downloads
#>
[CmdletBinding()]
param(
    [string]$Directory = "."
)

$ErrorActionPreference = 'Stop'

$resolvedDir = (Resolve-Path $Directory).Path
$firstPart = Get-ChildItem -Path $resolvedDir -Filter "*.iso.001" | Select-Object -First 1

if (-not $firstPart) {
    throw "No split ISO parts (*.iso.001) found in '$resolvedDir'."
}

$baseName = $firstPart.Name -replace '\.001$', ''
$targetIso = Join-Path $resolvedDir $baseName
$parts = Get-ChildItem -Path $resolvedDir -Filter "$baseName.*" | Where-Object { $_.Name -match "^$([regex]::Escape($baseName))\.\d{3}$" } | Sort-Object Name

Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " PalexusOS Split ISO Reassembly" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host "[*] Found $($parts.Count) parts for $baseName"
foreach ($part in $parts) {
    $sizeMB = [math]::Round($part.Length / 1MB, 1)
    Write-Host "    - $($part.Name) ($sizeMB MB)"
}

Write-Host "[*] Concatenating parts into $targetIso..."
$tempIso = "$targetIso.tmp"
if (Test-Path $tempIso) { Remove-Item -Force $tempIso }

$outStream = [System.IO.File]::Create($tempIso)
try {
    $buffer = New-Object byte[] (8 * 1024 * 1024) # 8 MB buffer
    foreach ($part in $parts) {
        Write-Host "    Merging $($part.Name)..."
        $inStream = [System.IO.File]::OpenRead($part.FullName)
        try {
            while (($bytesRead = $inStream.Read($buffer, 0, $buffer.Length)) -gt 0) {
                $outStream.Write($buffer, 0, $bytesRead)
            }
        } finally {
            $inStream.Dispose()
        }
    }
} finally {
    $outStream.Dispose()
}

if (Test-Path $targetIso) { Remove-Item -Force $targetIso }
Move-Item -Path $tempIso -Destination $targetIso -Force

$totalGB = [math]::Round((Get-Item $targetIso).Length / 1GB, 2)
Write-Host "[✓] Successfully created: $targetIso ($totalGB GB)" -ForegroundColor Green

# Checksum verification
$sumsFile = Join-Path $resolvedDir "SHA256SUMS"
if (Test-Path $sumsFile) {
    Write-Host "[*] Verifying SHA256 checksum against SHA256SUMS..."
    $lines = Get-Content $sumsFile
    $matched = $lines | Where-Object { $_ -match "[\s\*]$([regex]::Escape($baseName))$" } | Select-Object -Last 1
    if ($matched) {
        $expectedHash = ($matched.Trim() -split '\s+')[0].ToLower()
        Write-Host "    Expected: $expectedHash"
        $actualHash = (Get-FileHash -Path $targetIso -Algorithm SHA256).Hash.ToLower()
        Write-Host "    Actual:   $actualHash"
        if ($expectedHash -eq $actualHash) {
            Write-Host "[✓] Checksum matches! ISO is verified." -ForegroundColor Green
        } else {
            Write-Warning "Checksum mismatch! The reassembled file does not match SHA256SUMS."
        }
    } else {
        Write-Host "[i] No checksum entry for $baseName found in SHA256SUMS."
    }
}

Write-Host ""
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " PalexusOS ISO Ready to Test or Flash" -ForegroundColor Cyan
Write-Host "==============================================================================" -ForegroundColor Cyan
Write-Host " Test in Hyper-V: .\build\hyperv-vm.ps1 -Action Create -IsoPath `"$targetIso`""
Write-Host " Flash to USB:    Use Rufus (https://rufus.ie) or BalenaEtcher in ISO/DD mode."
Write-Host "==============================================================================" -ForegroundColor Cyan
