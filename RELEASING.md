# Releasing

This project publishes to [RubyGems](https://rubygems.org/gems/suncalc) via
GitHub Actions. The release workflow runs automatically when a `v*` tag is
pushed to the repository.

## One-time setup

RubyGems trusted publishing (OIDC) must be configured before the first
automated release. This is done **once**, in the RubyGems web UI:

1. Sign in to <https://rubygems.org> as an owner of the `suncalc` gem.
2. Navigate to the gem's page → **Trusted Publishers** → **Add**.
3. Fill in:
   - Repository owner: `gregmundy`
   - Repository name: `suncalc`
   - Workflow filename: `release.yml`
   - Environment: `rubygems`
4. Save.

In GitHub, create a matching environment named `rubygems`
(Repository → Settings → Environments → New environment). No secrets are
required — OIDC tokens are exchanged at release time.

## Cutting a release

1. Update `lib/suncalc/version.rb` to the new version (e.g. `1.2.0`).
2. Add a section to `CHANGELOG.md` for the new version, following the existing
   format. The release workflow extracts this section verbatim as the GitHub
   Release notes.
3. Commit and push to `main`.
4. Trigger the release. Either of the following works:

   **Option A — click the button (recommended):**
   GitHub → Actions → **Release** → **Run workflow** → choose `main` → Run.
   The workflow reads the version from `lib/suncalc/version.rb`, creates and
   pushes the matching `v*` tag for you, and proceeds to publish.

   **Option B — push the tag manually:**
   ```sh
   git tag v1.2.0
   git push origin v1.2.0
   ```

5. Either way the `Release` workflow then:
   - Verifies the version matches `SunCalc::VERSION`.
   - Verifies a matching section exists in `CHANGELOG.md`.
   - Runs the full test suite.
   - Builds the gem.
   - Publishes it to RubyGems via OIDC.
   - Creates a GitHub Release with the changelog excerpt and the `.gem`
     attached.

## If something goes wrong

- **Tag/version mismatch:** Delete the tag
  (`git push --delete origin v1.2.0`), fix `version.rb` or the tag, and run
  the workflow again.
- **CHANGELOG section missing:** The workflow refuses to release without a
  `## [VERSION]` section in `CHANGELOG.md`. Add one and re-run.
- **Tag already exists (button flow):** Bump `SunCalc::VERSION` first; the
  workflow will not overwrite an existing tag.
- **Tests fail at release time:** Tests must already be green on `main` — if
  the release workflow surfaces a failure that didn't appear in CI, suspect a
  Ruby-version-specific issue. The release runs on Ruby 3.4; CI covers 3.0,
  3.2, 3.4, and 4.0.
- **RubyGems publish fails with an authentication error:** The trusted
  publisher configuration is wrong or missing. Re-check the One-time setup
  section above.
