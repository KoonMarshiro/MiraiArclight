# MiraiArclight downstream patchset

This file records every intentional Mirai-only deviation from upstream Arclight.

## MIRAICORE-001 — NeoForge runtime pin

**State:** active

**Target:** NeoForge 21.1.230

**Reason:** This is the loader baseline proven against the Mirai 1.21.1 / Pixelmon 9.4.0 runtime. The older Arclight baseline used 21.1.228, which does not satisfy the LegacyForms requirement of NeoForge 21.1.229 or newer.

**Rule:** Do not bump NeoForge in Mirai branches merely because upstream bumps it. A newer loader must pass build, CoreLab, staging-world first boot, restart, clean shutdown and fatal-log scan.

**Rollback:** Restore the previous known-good Mirai production commit.

## MIRAICORE-002 — Remove redundant bootstrap SnakeYAML

**State:** active

**File:** `bootstrap/build.gradle`

**Reason:** PokeBossRaid 2.0.0-alpha.1 embeds `org.yaml.snakeyaml.*`. Upstream Arclight also adds standalone `org.yaml:snakeyaml` to bootstrap installer libraries. NeoForge JPMS then sees the same package in two modules and throws a split-package `ResolutionException` before game launch.

**Mirai behavior:** Do not add standalone SnakeYAML to the Arclight bootstrap installer for this server stack.

**Evidence:**
- Before patch: JPMS split-package failure involving `org.yaml.snakeyaml` and `pokebossraid`.
- After patch: exact RC1 commit `347c601b11a86ef0253527f444c9ea1ec530ebc3` reached `Done` in CoreLab and real staging-world.
- Staging shutdown saved all dimensions and exited 0.
- Production GitHub Build and Mirai NeoForge Build both passed.

**Dependency warning:** This patch assumes the Mirai runtime continues to provide SnakeYAML through the current mod stack. If PokeBossRaid packaging changes, re-run the full runtime gate before release.

## Regression guards

`scripts/verify-mirai-artifact.ps1` fails if:
- Minecraft drifts from 1.21.1.
- NeoForge drifts from 21.1.230.
- standalone SnakeYAML returns to installer metadata.
- the built jar manifest does not match the current source commit.

Every upstream sync must run this verifier before the artifact can be considered a Mirai release candidate.
