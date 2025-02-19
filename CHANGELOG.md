# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.0] - 2025-02-19

### Added

- Includes in the email message report the values of the following `Tower.Event` fields: `id`, `similarity_id`, `datetime` and `metadata`.

### Changed

- Email subject suffix in parenthesis changed from `Tower.Event.id` value to `Tower.Event.similarity_id` value. This should result in better grouping (a.k.a. conversation threads) of similar errors/events (tested in GMail).
- Email subject and body format updates to better resemble logger errors and messages format.
- Updates `tower` dependency from `{:tower, "~> 0.7.1"}` to `{:tower, "~> 0.7.5 or ~> 0.8.0"}`.

## [0.5.2] - 2024-11-19

### Changed

- Updates `tower` dependency from `{:tower, "~> 0.6.0"}` to `{:tower, "~> 0.7.1"}`.

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

[0.6.0]: https://github.com/mimiquate/tower_email/compare/v0.5.2...v0.6.0/
[0.5.2]: https://github.com/mimiquate/tower_email/compare/v0.5.1...v0.5.2/
[0.5.1]: https://github.com/mimiquate/tower_email/compare/v0.5.0...v0.5.1/
[0.5.0]: https://github.com/mimiquate/tower_email/compare/v0.4.0...v0.5.0/
[0.4.0]: https://github.com/mimiquate/tower_email/compare/v0.3.0...v0.4.0/
[0.3.0]: https://github.com/mimiquate/tower_email/compare/v0.2.0...v0.3.0/
[0.2.0]: https://github.com/mimiquate/tower_email/compare/v0.1.0...v0.2.0/
