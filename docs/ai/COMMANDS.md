# Validation commands

Run from a Discourse checkout with this repository installed under `plugins/discourse-crimson-community`.

- Ruby formatting/lint: `bundle exec rubocop`
- Syntax Tree formatting check: `bundle exec stree check plugin.rb app lib config db`
- One Ruby spec, only if the relevant spec exists: `LOAD_PLUGINS=1 bin/rspec plugins/discourse-crimson-community/spec/path/to/example_spec.rb`
- Plugin Ruby specs, only if specs exist: `bundle exec rake "plugin:spec[discourse-crimson-community]"`
- Plugin QUnit, only if frontend tests exist: `CI=1 bundle exec rake "plugin:qunit[discourse-crimson-community]"`
- After plugin migration changes: `LOAD_PLUGINS=1 bundle exec rake db:migrate`

The repository uses the official reusable `Discourse Plugin` GitHub Actions workflow. Treat only checks attached to the latest exact PR head as evidence. If an additional required Discourse-owned `Discourse CI` check is configured, it must be GREEN on the same head. Missing/stale/skipped CI is not GREEN.

Prefer privacy-specific targeted checks before broader suites. Never invent a missing test harness.
