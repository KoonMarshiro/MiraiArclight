$ErrorActionPreference = "Stop"
$Root = Resolve-Path (Join-Path $PSScriptRoot "..")
Set-Location $Root

if (& git status --porcelain) {
    throw "Working tree is not clean. Commit or stash changes first."
}

$devBranch = "mirai-1.21.1-neoforge-dev"
if (-not ((& git remote) -contains "upstream")) {
    & git remote add upstream https://github.com/IzzelAliz/Arclight.git
}

Write-Host "[MiraiArclight] Fetching upstream..."
& git fetch upstream
if ($LASTEXITCODE -ne 0) { throw "git fetch upstream failed" }

& git checkout FeudalKings
if ($LASTEXITCODE -ne 0) { throw "Cannot checkout FeudalKings" }
& git reset --hard upstream/FeudalKings
if ($LASTEXITCODE -ne 0) { throw "Cannot reset FeudalKings" }
& git push origin FeudalKings --force-with-lease
if ($LASTEXITCODE -ne 0) { throw "Cannot update origin/FeudalKings" }

& git checkout $devBranch
if ($LASTEXITCODE -ne 0) { throw "Cannot checkout $devBranch" }
& git merge --no-ff FeudalKings -m "chore: sync Arclight upstream"
if ($LASTEXITCODE -ne 0) {
    throw "Upstream merge needs manual conflict resolution. Dev branch was NOT pushed."
}

Write-Host "[MiraiArclight] Upstream merged locally. Build and run CoreLab before pushing dev."
