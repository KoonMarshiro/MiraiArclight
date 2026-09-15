$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

$javaLine = (& cmd /c "java -version 2>&1" | Select-Object -First 1)
if ($javaLine -notmatch 'version "21\.') {
    throw "Java 21 is required. Detected: $javaLine"
}

Write-Host "[MiraiArclight] Building Minecraft 1.21.1 / NeoForge..."
& .\gradlew.bat :bootstrap:neoforgeJar --no-daemon --stacktrace
if ($LASTEXITCODE -ne 0) { throw "Gradle build failed with exit code $LASTEXITCODE" }

$artifact = Get-ChildItem ".\bootstrap\build\libs\arclight-neoforge-1.21.1-*.jar" |
    Sort-Object LastWriteTime -Descending | Select-Object -First 1
if (-not $artifact) { throw "NeoForge artifact was not found." }

$dist = Join-Path $Root "dist"
New-Item -ItemType Directory -Force -Path $dist | Out-Null
$shortSha = (& git rev-parse --short=12 HEAD).Trim()
$fullSha = (& git rev-parse HEAD).Trim()
$outName = "MiraiArclight-NeoForge-1.21.1-$shortSha.jar"
$outPath = Join-Path $dist $outName
Copy-Item $artifact.FullName $outPath -Force

& (Join-Path $PSScriptRoot "verify-mirai-artifact.ps1") -Artifact $outPath
if ($LASTEXITCODE -ne 0) { throw "Mirai artifact verification failed." }

$hash = (Get-FileHash $outPath -Algorithm SHA256).Hash
Set-Content -Path "$outPath.sha256" -Value "$hash  $outName" -Encoding ascii

$info = [ordered]@{
    project = "MiraiArclight"
    minecraft = "1.21.1"
    loader = "NeoForge"
    upstream_branch = "FeudalKings"
    git_commit = $fullSha
    source_artifact = $artifact.Name
    output_artifact = $outName
    sha256 = $hash
    built_at = (Get-Date).ToString("o")
}
$info | ConvertTo-Json | Set-Content -Path (Join-Path $dist "build-info.json") -Encoding utf8

Write-Host ""
Write-Host "[MiraiArclight] BUILD PASS"
Write-Host "Artifact: $outPath"
Write-Host "SHA-256: $hash"
