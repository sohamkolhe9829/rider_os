# Coding Guidelines

To maintain an enterprise-level, production-ready codebase, RiderOS adheres to the following strict coding guidelines.

## 1. Architecture
We use a **Feature-First** directory structure.
```
lib/
  features/
    feature_name/
      presentation/
        screens/
        widgets/
        providers/
      domain/
      data/
```
- **Presentation**: UI widgets, Riverpod consumers, and state controllers.
- **Domain**: Business logic, entity models, and abstract repository interfaces.
- **Data**: API implementations, local storage (Hive), and repository concretions.

## 2. State Management (Riverpod)
- Never use `StatefulWidget` for global state. Use Riverpod's `StateNotifierProvider` or `NotifierProvider`.
- Inject dependencies via Providers. Do not use Singletons (`MyClass._instance`).
- Keep Providers small and scoped.

## 3. Formatting and Linting
- All code must pass `flutter analyze` without any warnings.
- All code must be formatted using `dart format`.
- Use the `analysis_options.yaml` provided in the repository root. It includes strict linting rules.

## 4. Null Safety
- RiderOS requires strict null safety.
- Avoid using the bang operator (`!`) unless absolutely necessary and proven safe by context. Prefer explicit null checks (`if (val != null)`).

## 5. Documentation
- Write Dartdoc comments (`///`) for all public classes, methods, and providers.
- Explain *why* the code exists, not just *what* it does.

## 6. Testing
- Write unit tests for all business logic (`domain/` and `data/`).
- Use Golden tests for complex UI components (`presentation/`).
- CI will fail if tests do not pass. Ensure `flutter test` succeeds locally before pushing.
