# Release Checklist

This step-by-step checklist must be strictly followed before publishing any release of RiderOS.

- [ ] **1. Update Version**: Increment the `version` field in `pubspec.yaml` following Semantic Versioning (`Major.Minor.Patch+Build`).
- [ ] **2. Update Changelog**: Add a new entry in `CHANGELOG.md` with the exact version number matching `pubspec.yaml` and the release date. Ensure sections for `Added`, `Changed`, `Fixed`, etc., are present.
- [ ] **3. Run Formatter**: Ensure code is perfectly formatted.
      ```bash
      dart format --set-exit-if-changed .
      ```
- [ ] **4. Run Analyzer**: Ensure zero static analysis warnings.
      ```bash
      flutter analyze
      ```
- [ ] **5. Run Tests**: Ensure all unit and widget tests pass.
      ```bash
      flutter test
      ```
- [ ] **6. Build Release APK (Dry Run)**: Verify the APK builds locally.
      ```bash
      flutter build apk --release
      ```
- [ ] **7. Build App Bundle (Dry Run)**: Verify the AAB builds locally.
      ```bash
      flutter build appbundle --release
      ```
- [ ] **8. Create Git Tag**: Tag the commit with the exact `pubspec.yaml` version.
      ```bash
      git tag vX.Y.Z+B
      ```
- [ ] **9. Push Tag**: Push the tag to trigger the `release.yml` GitHub Action.
      ```bash
      git push origin vX.Y.Z+B
      ```
- [ ] **10. Verify GitHub Actions**: Monitor the `Release Pipeline` in the GitHub Actions tab. Ensure it passes without errors.
- [ ] **11. Verify GitHub Release**: Check the GitHub Releases page to ensure the release notes were automatically parsed and the APK/AAB artifacts are attached.
- [ ] **12. Test APK**: Download the APK from the release and test it on a physical device to ensure signing worked correctly.
- [ ] **13. Test AAB (Optional but recommended)**: Use `bundletool` to verify the App Bundle locally.
- [ ] **14. Upload to Google Play Console**: Once verified, upload the AAB to the Internal Testing track on the Google Play Console.
