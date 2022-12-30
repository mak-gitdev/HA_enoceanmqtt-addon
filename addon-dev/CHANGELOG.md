## 0.1.23

**Note**: Rename versions in changelog

### Changed
- Rename not rounded entities `xx_temperature` and `xx_humidity` from A5-04-XX devices to `t_raw` and
  `h_raw`. These new entities are also disable by default.

### Added
- Add support for:
  - A5-02-[01-0B]
  - A5-02-[10-1B]
  - A5-02-20
  - A5-02-30
  - A5-06-[01-02]
  - A5-07-[01-03]
  - A5-13-01
  - D2-03-0A

### Removed
- Remove °F entities from A5-04-XX devices as HA seems to convert automatically °C to °F and vice-versa

### Fixed
- Fix issue mak-gitdev/HA_enoceanmqtt#27
- Fix status entity for A5-04-XX devices.

## 0.1.22 (previously `dev` in addon and `20221125-1` in changelog)
First version of addon-dev to track the develop branch

### Added
- Add support for A5-04-[01-04] devices

### Fixed
- Fix issue #10