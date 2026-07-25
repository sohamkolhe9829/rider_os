# GitHub Workflow Guidelines

RiderOS leverages GitHub Actions to enforce strict CI/CD validation. No code reaches the `main` branch or production without passing these automated checks.

## Branch Strategy
- **`main`**: Protected branch. Represents the latest stable production build. Receives merges only from `dev`. No production releases ever originate from `dev`.
- **`dev`**: The primary integration branch. All features, bugfixes, and enhancements must be merged here via Pull Requests. Every push triggers the CI pipeline.

## Branch Protection Rules (Mandatory Configuration)

The repository administrator must enable the following branch protection rules in GitHub Settings.

### `main` Branch Rules
- **Require Pull Request reviews before merging**: Ensures at least one other engineer has verified the code quality and logic.
- **Require status checks to pass before merging**: Blocks merges if the `flutter_ci` workflow fails.
- **Require branches to be up to date before merging**: Prevents merging stale code that might break production.
- **Disable direct push**: Forces all changes through the PR process, ensuring CI always runs.
- **Disable force push**: Prevents rewriting production history.
- **Require linear history (optional but recommended)**: Keeps the commit graph clean and revertible.

### `dev` Branch Rules
- **Require passing CI before merge**: Ensures no broken code enters the main development stream.
- **Block force pushes**: Prevents developers from overwriting each other's work on the shared integration branch.
- **Restrict direct merges**: Forces feature branches to go through PRs.

## CI Workflow (`flutter_ci.yml`)
The CI workflow runs on every push to `dev` and every PR targeting `main`.
It strictly checks:
- **Formatting**: Validates `dart format` output.
- **Analysis**: Validates `flutter analyze`.
- **Testing**: Validates `flutter test`.
- **Build**: Builds a debug APK to ensure compilation succeeds.
Any failure blocks the PR from being merged.
