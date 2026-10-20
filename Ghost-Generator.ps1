$ErrorActionPreference = 'Stop'

$baseDirectory = if (-not [string]::IsNullOrWhiteSpace($PSScriptRoot)) {
    $PSScriptRoot
} else {
    [System.AppDomain]::CurrentDomain.BaseDirectory
}
$ghostPath = Join-Path $baseDirectory 'ghost.txt'
if (-not (Test-Path -LiteralPath $ghostPath -PathType Leaf)) {
    Write-Error 'ghost.txt must be next to Ghost-Generator.exe.'
    exit 1
}

$ghost = Get-Content -LiteralPath $ghostPath

# Maximize the console before drawing the ASCII art.
# F11 is not a reliable fullscreen shortcut for the classic Windows console.
try {
    if (-not ('GhostGeneratorConsole' -as [type])) {
        Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

public static class GhostGeneratorConsole
{
    [DllImport("kernel32.dll")]
    private static extern IntPtr GetConsoleWindow();

    [DllImport("user32.dll")]
    private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

    public static void Maximize()
    {
        IntPtr handle = GetConsoleWindow();
        if (handle != IntPtr.Zero)
        {
            ShowWindow(handle, 3); // SW_MAXIMIZE
        }
    }
}
'@
    }
    [GhostGeneratorConsole]::Maximize()
    Start-Sleep -Milliseconds 250
} catch {
    # Keep running normally if Windows does not allow console resizing.
}

$host.UI.RawUI.BackgroundColor = 'Black'
$host.UI.RawUI.ForegroundColor = 'White'
Clear-Host
$ghost | ForEach-Object { Write-Host $_ }

# Enter is intentionally the only way to start; no prompt is displayed.
while ($true) {
    $key = [Console]::ReadKey($true)
    if ($key.Key -eq [ConsoleKey]::Enter) { break }
}

# Three-second countdown on a white console background.
$oldBackground = $host.UI.RawUI.BackgroundColor
$oldForeground = $host.UI.RawUI.ForegroundColor
$host.UI.RawUI.BackgroundColor = 'White'
$host.UI.RawUI.ForegroundColor = 'Black'

foreach ($number in @(3, 2, 1)) {
    Clear-Host
    $window = $host.UI.RawUI.WindowSize
    $line = [string]$number
    $left = [Math]::Max(0, [int](($window.Width - $line.Length) / 2))
    $top = [Math]::Max(0, [int]($window.Height / 2))
    $host.UI.RawUI.CursorPosition = [System.Management.Automation.Host.Coordinates]::new($left, $top)
    Write-Host $line -NoNewline
    Start-Sleep -Seconds 1
}

$host.UI.RawUI.BackgroundColor = 'Black'
$host.UI.RawUI.ForegroundColor = 'White'
Clear-Host

Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$count = 0
$totalBytes = [long]0
$running = $true

while ($running) {
    # Each valid empty ZIP is 22 bytes. The name gains one extra 'o' per file.
    $nextCount = $count + 1
    $fileName = 'Gh' + ('o' * $nextCount) + 'st.zip'
    $filePath = Join-Path $baseDirectory $fileName

    # Windows file systems limit a single filename component to 255 characters.
    if ($fileName.Length -gt 255) { break }

    try {
        $stream = [System.IO.File]::Open($filePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::ReadWrite, [System.IO.FileShare]::None)
        try {
            $archive = [System.IO.Compression.ZipArchive]::new($stream, [System.IO.Compression.ZipArchiveMode]::Create, $false)
            $archive.Dispose()
        }
        finally {
            $stream.Dispose()
        }

        $size = (Get-Item -LiteralPath $filePath).Length
        $count = $nextCount
        $totalBytes += $size

        Write-Host 'Boo! ' -NoNewline -ForegroundColor White
        Write-Host $count -NoNewline -ForegroundColor Red
        Write-Host ' Files Created' -ForegroundColor White
    }
    catch {
        # Stop rather than report a file that was not actually created.
        $running = $false
        break
    }

    # Poll frequently so Esc stops the loop promptly while preserving the 0.2 s rhythm.
    for ($tick = 0; $tick -lt 10; $tick++) {
        if ([Console]::KeyAvailable) {
            $pressed = [Console]::ReadKey($true)
            if ($pressed.Key -eq [ConsoleKey]::Escape) {
                $running = $false
                break
            }
        }
        Start-Sleep -Milliseconds 20
    }
}

Write-Host ''
Write-Host ('Files Created: {0}' -f $count) -ForegroundColor White
Write-Host ('Total ZIP size: {0} bytes ({1:N2} KB)' -f $totalBytes, ($totalBytes / 1KB)) -ForegroundColor White
Write-Host ''
Start-Sleep -Seconds 2

# The ghost briefly returns before the process exits.
$host.UI.RawUI.BackgroundColor = 'Black'
$host.UI.RawUI.ForegroundColor = 'White'
Clear-Host
$ghost | ForEach-Object { Write-Host $_ }
Start-Sleep -Milliseconds 600
