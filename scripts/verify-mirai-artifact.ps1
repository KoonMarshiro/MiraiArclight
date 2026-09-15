param(
    [string]$Artifact
)

$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")

$versionsFile = Join-Path $Root "gradle\libs.versions.toml"
$versions = Get-Content $versionsFile -Raw

if (-not $versions.Contains("minecraft = '1.21.1'")) {
    throw "Mirai target drift: minecraft must remain 1.21.1."
}
if (-not $versions.Contains("neoforge = '21.1.230'")) {
    throw "Mirai target drift: NeoForge must remain 21.1.230 until a newer loader passes the runtime gate."
}

if (-not $Artifact) {
    $candidate = Get-ChildItem (Join-Path $Root "bootstrap\build\libs\arclight-neoforge-1.21.1-*.jar") |
        Sort-Object LastWriteTime -Descending |
        Select-Object -First 1
    if (-not $candidate) {
        throw "NeoForge artifact not found."
    }
    $Artifact = $candidate.FullName
} else {
    $Artifact = (Resolve-Path $Artifact).Path
}

Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [System.IO.Compression.ZipFile]::OpenRead($Artifact)
try {
    function Read-ZipText([string]$name) {
        $entry = $zip.GetEntry($name)
        if (-not $entry) { throw "Missing jar entry: $name" }
        $reader = New-Object System.IO.StreamReader($entry.Open())
        try { return $reader.ReadToEnd() } finally { $reader.Dispose() }
    }

    $installer = Read-ZipText "META-INF/installer.json"
    if ($installer -match "org\.yaml:snakeyaml" -or $installer -match "snakeyaml-[0-9]") {
        throw "Mirai compatibility regression: standalone SnakeYAML returned to installer metadata."
    }

    $manifest = Read-ZipText "META-INF/MANIFEST.MF"
    $short = (& git -C $Root rev-parse --short=8 HEAD).Trim()
    if ($manifest -notmatch ("Implementation-Version: .*-" + [regex]::Escape($short))) {
        throw "Artifact/source mismatch: manifest does not contain current commit $short."
    }
}
finally {
    $zip.Dispose()
}

Write-Host "[MiraiArclight] ARTIFACT VERIFY PASS"
Write-Host "Minecraft: 1.21.1"
Write-Host "NeoForge: 21.1.230"
Write-Host "Standalone bootstrap SnakeYAML: absent"
Write-Host "Artifact/source commit: matched"
