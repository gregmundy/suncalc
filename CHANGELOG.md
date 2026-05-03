# Changelog

All notable changes to this project are documented in this file. The format is
based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this
project adheres to [Semantic Versioning](https://semver.org/).

## [1.1.1] — 2026-05-03

No functional changes to the library. This release validates the GitHub
Actions release pipeline end-to-end after a fix to the `.gem` artifact
upload step in 1.1.0's release run.

### Changed

- Internal: release workflow now builds the gem locally before attaching
  it to the GitHub Release page; the `rubygems/release-gem` action does
  not leave the artifact in the working directory after publishing.
- Bumped `actions/checkout` to v6 in the CI and Release workflows to
  clear the upcoming Node 20 deprecation.

## [1.1.0] — 2026-05-03

This release brings the Ruby port back in line with upstream
[suncalc.js](https://github.com/mourner/suncalc) v1.9.0 and fixes two
correctness bugs that have been present since the original release.

### Fixed

- **Moon altitude refraction.** The atmospheric refraction correction applied
  in `get_moon_position` used dimensionally inconsistent constants, producing
  altitudes that were noticeably wrong near the horizon and a division-by-zero
  singularity at `h ≈ -0.0890` rad. The corrected Meeus formula 16.4 is now
  used and inputs below the horizon are clamped, matching upstream behavior.
- **`get_moon_times` day boundary.** Previously the start-of-day was
  constructed with `Time.new(...).utc`, which interprets components in the
  host machine's local timezone before converting to UTC. The day boundary is
  now built with `Time.utc(...)` so results no longer depend on `$TZ`.

### Added

- `SunCalc.astro_refraction(h)` — public helper exposing the corrected
  refraction calculation.
- `SunCalc.observer_angle(height)` — helper that converts an observer's
  elevation in meters to the corresponding horizon-angle correction.
- `SunCalc.get_times(date, lat, lng, height = 0)` — optional fourth argument
  for observer height in meters. A height of 2000 m, for example, advances
  sunrise by roughly ten minutes.
- `SunCalc.get_moon_position` now returns `:parallactic_angle` (Meeus formula
  14.1) alongside the existing fields.
- `SunCalc.get_moon_times(date, lat, lng, in_utc = true)` — optional fourth
  argument selects the local timezone for the day boundary when set to
  `false`. Defaults to `true` to preserve prior intended behavior.
- `SunCalc.get_moon_illumination` — `date` is now optional and defaults to
  `Time.now`.

### Changed

- Test suite expectations updated to the canonical values produced by upstream
  suncalc.js v1.9.0.
- Loose `be_within(100000)` (≈28 hour) tolerance on moon-times assertions
  replaced with a strict ±60 second check.
- Development dependencies updated: dropped EOL `bundler ~> 1.7` constraint,
  bumped `rake ~> 13.0`, pinned `rspec ~> 3.13`.

### Notes

- The `:alwaysUp` / `:alwaysDown` keys returned by `get_moon_times` remain
  camelCase for backward compatibility. They will be renamed to `:always_up`
  and `:always_down` in 2.0.

## [1.0.1] — 2016-03-05

- Miscellaneous fixes prior to the first stable release on RubyGems.

## [1.0.0] — 2015-01

- Initial release. Ruby port of suncalc.js covering sun position, sun times,
  moon position, moon illumination, and moon rise/set times.

[1.1.1]: https://github.com/gregmundy/suncalc/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/gregmundy/suncalc/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/gregmundy/suncalc/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/gregmundy/suncalc/releases/tag/v1.0.0
