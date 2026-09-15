# MiraiArclight

MiraiArclight is the Mirai Pixelmon downstream fork of Arclight.

## Supported target

- Minecraft: 1.21.1
- Loader: NeoForge only
- Java: 21
- Pixelmon runtime target: 9.4.0
- Upstream: `IzzelAliz/Arclight:FeudalKings`
- Fork base: `166b9877e40eeec405097f416fc0ff2d23986313`
- Upstream NeoForge pin at fork base: `21.1.248`

Forge/Fabric modules stay untouched to keep upstream syncing low-conflict. Mirai validation and release support target NeoForge only.

## Verified pre-fork runtime reference

- Minecraft 1.21.1
- Pixelmon 9.4.0
- NeoForge 21.1.230
- Arclight core commit `0769551`
- Server reached `Done`

Pixelmon 9.4.0 declares NeoForge `[21.1.0,)`; 21.1.248 is metadata-compatible but remains runtime-unverified until CoreLab passes.

## Branch policy

- `FeudalKings`: clean upstream mirror; no Mirai patches.
- `mirai-1.21.1-neoforge-dev`: development and validation.
- `mirai-1.21.1-neoforge-production`: tested promotions only.

## Runtime gate

1. Build `:bootstrap:neoforgeJar` from Java 21.
2. Boot the isolated Mirai CoreLab, never the live world.
3. Confirm NeoForge, Pixelmon, LegacyForms, Faction Heist and PokeBossRaid load.
4. Confirm the server reaches `Done`.
5. Compare new exceptions/errors against the known staging baseline.
6. Issue `stop` and confirm a clean shutdown.
7. Promote the exact tested commit only; keep the previous production commit as rollback.

## Build and sync

- One-click Windows build: `BUILD_MIRAI_NEOFORGE.cmd`
- Direct build: `gradlew.bat :bootstrap:neoforgeJar --no-daemon`
- Upstream sync: `powershell -ExecutionPolicy Bypass -File scripts/sync-upstream.ps1`

## License

Arclight is GPL-3.0. MiraiArclight remains subject to the upstream GPL-3.0 terms and corresponding-source obligations when distributed.
