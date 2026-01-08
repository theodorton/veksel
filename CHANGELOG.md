## [](https://github.com/theodorton/veksel/compare/v0.3.0...v) (2024-12-02)


### Features

* support any rails version from 7.1 and up ([27fbabd](https://github.com/theodorton/veksel/commit/27fbabd2c0d36697086dabc845849e2ed67d88d9))
* support Ruby 4


### Bug Fixes

* case/when fallthrough expected ([2b3161e](https://github.com/theodorton/veksel/commit/2b3161e687a0e700d7f0f57659a9511b7f9ac6b1))

## [](https://github.com/theodorton/veksel/compare/v0.3.0...v) (2024-12-02)


### Bug Fixes

* case/when fallthrough expected ([2b3161e](https://github.com/theodorton/veksel/commit/2b3161e687a0e700d7f0f57659a9511b7f9ac6b1))

## [0.3.0](https://github.com/theodorton/veksel/compare/v0.2.2...v0.3.0) (2024-09-04)

### ⚠ BREAKING CHANGES

- Veksel.prefix has been removed
- Veksel.suffix no longer has a leading underscore
- CLI: suffix command has been removed

### Bug Fixes

- support database.yml with explicit primary ([99ecb90](https://github.com/theodorton/veksel/commit/99ecb902f010a42c45c2b113c404036617addc69))

## [0.2.2](https://github.com/theodorton/veksel/compare/v0.2.1...v0.2.2) (2024-03-12)

### Bug Fixes

- support ERB in database.yml ([9ae2aef](https://github.com/theodorton/veksel/commit/9ae2aefd5a8c6fc2fe445eb63ec8f9d3647389f4))

## [0.2.1](https://github.com/theodorton/veksel/compare/v0.2.0...v0.2.1) (2024-03-10)

### Bug Fixes

- Require fileutils as it's not loaded by default in some Ruby versions. ([66833d0](https://github.com/theodorton/veksel/commit/66833d01ee19345de26435bf267ca41f650d3931))

## [0.2.0](https://github.com/theodorton/veksel/compare/v0.1.0...v0.2.0) (2024-02-29)

### ⚠ BREAKING CHANGES

- database.yml should no longer be modified, but define the default dev database name instead. Veksel will hook into the Rails environment with ActiveRecord::DatabaseConfigurations.register_db_config_handler

### Bug Fixes

- missing status variable assignment ([1bcfab2](https://github.com/theodorton/veksel/commit/1bcfab2f502bca2add9b682b85c2561a3aea2bb8))
- remove unused files from dummy app ([06a5e8d](https://github.com/theodorton/veksel/commit/06a5e8df9006acb1f96cb1927654a8b6b288779e))
- update appraisal ([f7c726d](https://github.com/theodorton/veksel/commit/f7c726d829d9af2dbb27ad81d57f4eb7dddf73a6))

### Performance Improvements

- faster invocation without loading rails env ([3c09e54](https://github.com/theodorton/veksel/commit/3c09e54d66e95acdaa5b5bf9e056cd68176cde8c))
- fork using templates instead of pg_dump ([7ebfa62](https://github.com/theodorton/veksel/commit/7ebfa628ded36ea4531c9ca446340ed99777e8bb))

## 0.1.0 (2024-02-27)

- initial release
