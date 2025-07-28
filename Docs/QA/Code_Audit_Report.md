# Code Audit Report

## Overview
- Added SwiftLint config (lint execution unavailable on Linux).
- Removed outdated Core capture manager and redundant CIImage extension.
- Fixed force unwraps and cleaned imports.
- Replaced remaining force unwraps in processing modules.
- Improved accessibility across UI views.
- Applied file protection for saved data and updated privacy usage.
- Added unit tests and CI workflow for testing and SwiftLint.

## File Fixes
- `AstroCaptureManager.swift` – safer file paths and file protection.
- `PlannerViewModel.swift` – avoid force unwrap and weak self in tasks.
- `CloudExporter.swift` – removed UIKit import, added file protection.
- `UI` views – accessibility labels.
- `AIDenoiser.swift` & `SuperResolution.swift` – removed force unwraps.
- `UI` views – dynamic colors for Dark Mode.
- `RAWPhotoDelegate.swift` – cleaned TODO comment.
- `project.yml` – added test target and warnings-as-errors.

## Remaining TODO
- Light pollution service to parse GeoJSON.
- Calibration capture functions for dark/flat/bias (in Capture manager).
- SwiftLint integration in CI once binary available on macOS runner.

## Checks
- HIG: basic accessibility labels added.
- OWASP: no hardcoded credentials, HTTPS only, file protection enabled.
- Lint: configuration added but not executed in this environment.
- Performance: addressed potential retain cycle in async tasks.

