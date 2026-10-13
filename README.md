# Calculator State Lab — Assignment 01

CSC 4360 undergraduate • Mohamed Mohamed

A Flutter calculator with **exactly three selected enhancements**: light/dark theme toggle, All Clear (AC), and recoverable error handling. Arithmetic is left to right: `2 + 3 × 4 = 20`.

## Setup, run, and build

Verified with Flutter 3.47.2 / Dart 3.13.2. Install Flutter and the Android SDK, then run:

```sh
flutter pub get
flutter devices
flutter run -d <android-device-id>
flutter build apk
```

APK: `build/app/outputs/flutter-apk/app-release.apk`. Install it with `adb install -r build/app/outputs/flutter-apk/app-release.apk`. The generated Android configuration signs the release-mode APK using the local debug key, suitable for this sideloaded class assignment; no signing keys are committed.

## State contract and boundaries

`lib/calculator_model.dart` owns the accumulator, operand string, pending operator, awaiting-operand flag, result-completed flag, and recoverable error. Getters expose state; only action methods mutate it. `displayText` and `contextText` are derived. `lib/main.dart` renders the model from a StatefulWidget using setState and separately owns the theme flag and accessibility announcement.

- A digit after an operator starts a new operand.
- An operator after an entered operand applies the pending operation, shows the running total, then stores the new operator.
- Operators entered while awaiting an operand replace the pending operator.
- Equals without a pending operation or without a new operand is ignored. `7 + =` keeps display 7 and pending +; `2 =` then gives 9.
- Repeated equals is ignored. A digit after a completed result starts fresh.
- An operator after equals continues from the result. An initial operator uses zero as the left operand.
- Leading zeros collapse (`0 0 1 2` becomes 12). Equals on a standalone operand is ignored, so `7 = 2` enters 72.
- AC clears every calculation field, including errors. It does not change the selected theme.
- Division produces fractional results without a decimal-input key. Input is limited to 15 digits with an explicit recoverable error; results display up to 12 significant digits. Full finite double precision is retained internally. Scientific notation is possible. Extremely small results can round/underflow as with IEEE-754 doubles; this is not arbitrary-precision arithmetic.

## Error recovery

Division by zero, non-finite results, and overlong input display a text explanation plus a recovery instruction. Operators/equals are ignored during an error. Any digit resets the calculation and begins new input; AC resets to 0. Incomplete expressions show `enter a number` while preserving the core ignored-equals contract.

## Verification

```sh
dart format --output=none --set-exit-if-changed lib test tool
flutter analyze
flutter test --reporter expanded
dart run tool/trace.dart
```

On October 12, 2026, the automated suite passed **30 tests** (23 model, 7 widget); analyzer: **no issues**. Tests cover intermediate totals, operator replacement, incomplete and repeated equals, all four operators, leading zeros, fractional results, all AC phases, stale accumulators, error recovery, overflow, display rounding, theme state preservation, and semantics. The targeted test `agent AC probes validate reset before operator or digit` additionally verifies both services’ exact post-AC continuations and every internal reset field.

Widget tests check 320×640 logical pixels at 1×, 2× and 3× text scales, reachable controls with at least 48×48 logical-pixel targets, operator/theme labels, committed-result live regions, and Flutter's text-contrast/labeled-target guidelines in both themes including errors. The vertically scrollable layout keeps essential keys reachable at large text sizes; long numeric displays scroll horizontally. These automated checks do not replace a TalkBack listening/focus-order test or testing on a physical phone.

## Accessibility and selected features

Material color schemes cover background, display, controls, labels, and error surfaces. Theme changes animate over 300 ms and preserve calculation state. Errors have text, not just color. Digits remain readable by focusing the display; a separate live region announces committed totals and errors instead of every entered digit. Native visual reading order is title/theme, context/display, AC/divide, number/operator rows, zero/equals. TalkBack timing and focus behavior require student review.

## AI disclosure and remaining requirements

OpenAI Codex assisted with the implementation, tests, device automation, documentation, and repository preparation. Automated work is not represented as student-performed manual testing. Review and understand this code and follow the course's AI-use policy.

**Not submission-ready:** the two Test Drive comparisons are complete from the student-supplied Gemini and ChatGPT responses dated October 12, 2026. The separate Reflection 06 architecture responses/comparison remain pending; Prompt 2 cannot substitute for that prompt. The complete reflection wording was recovered from the matching official alternate-edition page. The implementation rationale is an AI-assisted draft for student review. Confirm the LMS deadline timezone and submission folder independently; the guide states October 12, 2026 at 11:59 PM without a timezone. No LMS submission was performed.

Assignment source: https://codd.cs.gsu.edu/~lhenry23/mad/hw/hw01/index2.html#top

The release APK was built, installed, and smoke-tested on a Pixel 7 Android 17 emulator (1080×2400, density 420). All 19 device checkpoints passed using Android taps and UI-tree assertions; see `docs/release-smoke.json`. Screenshots were visually inspected for light/dark results and text error recovery. The untouched starter also built and launched before UI changes. Initial `flutter doctor` reported missing Android command-line tools/unknown licenses and incomplete Xcode; the Android debug and release builds nevertheless succeeded with the installed SDK. No physical-device or TalkBack listening test was performed.
