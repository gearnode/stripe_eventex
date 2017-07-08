# Changelog for StripeEventex v2.0

## v2.0-dev

### 1. Enhancements
- Use elixir 1.4
- `cowboy` and `plug` dependencies are now optional and only on test env
- Use last version of `poison` (3.0)
- Possible to subscribe on same event with different func
- Use function instead of module to perform job

### 2. Bug fixes
- Remove all warning at compile time
- Fix bad raise condition message when `validation` params is missing

### 4. Deprecations
- Support of `MyModule.perform` ended, now use function instead `&MyModule.perform/1`
