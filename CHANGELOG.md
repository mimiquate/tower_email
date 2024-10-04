# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.5.1] - 2024-10-04

### Added

- Can include less verbose `TowerEmail` module as reporter instead of `TowerEmail.Reporter`.

## [0.5.0] - 2024-10-04

### Changed

- No longer necessary to call `Tower.attach()` in your application `start`. It is done
automatically.

- Updates `tower` dependency from `{:tower, "~> 0.5.0"}` to `{:tower, "~> 0.6.0"}`.

## [0.4.0] - 2024-08-22

### Changed

- Updated namespace to avoid clashing with `Tower`:
  - Changed reporter name from `Tower.Email.Reporter` to `TowerEmail.Reporter`.
  - Changed mailer name from `Tower.Email.Mailer` to `TowerEmail.Mailer`.

## [0.3.0] - 2024-08-20

### Added

- Bandit support via `tower` update
- Oban support via `tower` update

### Changed

- Updates dependency to `{:tower, "~> 0.5.0"}`.

## [0.2.0] - 2024-08-16

### Changed

- Updates dependency to `{:tower, "~> 0.4.0"}`.

[0.5.1]: https://github.com/mimiquate/tower_email/compare/v0.5.0...v0.5.1/
[0.5.0]: https://github.com/mimiquate/tower_email/compare/v0.4.0...v0.5.0/
[0.4.0]: https://github.com/mimiquate/tower_email/compare/v0.3.0...v0.4.0/
[0.3.0]: https://github.com/mimiquate/tower_email/compare/v0.2.0...v0.3.0/
[0.2.0]: https://github.com/mimiquate/tower_email/compare/v0.1.0...v0.2.0/
