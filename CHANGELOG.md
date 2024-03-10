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
