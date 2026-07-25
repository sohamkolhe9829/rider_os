# Release Process

RiderOS uses a highly automated Release Pipeline (`release.yml`) triggered by Git tags.

## Semantic Versioning

RiderOS strictly adheres to Semantic Versioning: `Major.Minor.Patch+Build`.
Example: `1.0.0+15`

## Step-by-Step Release Flow

1. **Development & Verification (dev)**
   Features and bugfixes are merged into `dev`. Once `dev` is deemed stable for a release, a PR is opened from `dev` to `main`.

2. **Update Version and Changelog**
   In the release PR (or just before creating the tag on `main`), the following files must be updated:
   - `pubspec.yaml`: Update the `version` field (e.g., `version: 1.1.0+16`).
   - `CHANGELOG.md`: Create a new release entry detailing the changes under the new version header (e.g., `## [1.1.0+16] - YYYY-MM-DD`).

3. **Merge to Main**
   Merge the Release PR into the `main` branch.

4. **Tag the Release**
   Create a Git tag matching the `pubspec.yaml` version exactly, prefixed with a `v`:
   ```bash
   git tag v1.1.0+16
   git push origin v1.1.0+16
   ```

5. **GitHub Actions (`release.yml`)**
   Pushing the tag triggers the Release Workflow, which executes the following automatically:
   - Validates the tag against `pubspec.yaml`.
   - Validates that a matching version header exists in `CHANGELOG.md`.
   - Re-runs tests and static analysis.
   - Decodes GitHub Secrets to securely sign Android builds.
   - Builds a signed Release APK and App Bundle (AAB).
   - Extracts the relevant release notes from `CHANGELOG.md`.
   - Creates a new GitHub Release, attaching the APK and AAB, and sets it as the "Latest Release".

6. **Play Store Deployment**
   The generated AAB from the GitHub Release can then be downloaded and uploaded to the Google Play Console for Internal, Closed, or Production tracks.
