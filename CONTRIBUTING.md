# Contributing to RiderOS

First off, thank you for considering contributing to RiderOS! It's people like you that make RiderOS such a great project.

## Branching Strategy

This project uses a strict branching model:
- `main`: Production-ready code only. All commits must be merged via Pull Requests. No direct commits.
- `dev`: The active development branch. All feature branches must target `dev`.

### Naming Branches

When creating a new branch from `dev`, please follow these conventions:
- `feature/your-feature-name` (e.g., `feature/dashboard-redesign`)
- `bugfix/issue-description` (e.g., `bugfix/speedometer-crash`)
- `hotfix/critical-issue` (Only used for critical production fixes targeting `main`)

## Development Setup

1. Ensure you have **Flutter 3.44.0** and **Java 21** installed.
2. Fork the repository.
3. Clone your fork and checkout `dev`.
4. Run `flutter pub get`.
5. *(Important)* Generate Hive adapters if you modify models:
   ```bash
   dart run build_runner build --delete-conflicting-outputs
   ```
   **Note:** We commit `*.g.dart` files. Do not expect GitHub Actions to generate them for you.

## Making Changes

- Ensure your code follows the [Coding Guidelines](docs/coding_guidelines.md).
- Run `flutter analyze` and `flutter test` locally before committing.
- Commit your changes using descriptive commit messages.

## Submitting a Pull Request

1. Push your branch to your fork.
2. Open a Pull Request targeting the `dev` branch.
3. Use the provided Pull Request Template to describe your changes.
4. Ensure all CI checks pass. If they fail, fix the issues and push again.
5. Request a review from the repository maintainers.

## Code of Conduct

Please note that this project is released with a [Code of Conduct](CODE_OF_CONDUCT.md). By participating in this project you agree to abide by its terms.
