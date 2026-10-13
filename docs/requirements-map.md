# Requirement / implementation / evidence

| Requirement | Implementation | Verification |
| --- | --- | --- |
| Digits 0–9; four operators; equals | main.dart key rows, model action methods | model tests and widget UI traces |
| Readable responsive display, pending context | derived displayText/contextText; scrollable constrained layout | 320px, 1×/2×/3× tests; release screenshots |
| StatefulWidget + setState | CalculatorApp / _CalculatorAppState | source inspection; theme and input widget tests |
| Left-to-right running total | chooseOperator applies pending operation | running total is left to right with intermediate displays |
| Digit after operator | awaitingOperand clears input on digit | all-four chain and core trace tests |
| Replace repeated operator | chooseOperator leaves accumulator intact when awaiting | operator replacement uses the original accumulator |
| Ignore incomplete equals | equals guard | incomplete equals preserves pending operation and resumes |
| Fresh digit after equals | digit clears completed-result phase | digit after equals starts fresh and repeated equals is inert |
| Theme toggle | MaterialApp themeMode, 300ms transition | theme switching during entry and result; contrast tests |
| AC resets all state | clear() | six AC-phase tests plus two stale-accumulator tests |
| Division by zero / errors | _fail and digit/AC recovery | two zero-division tests, input-limit and nonfinite-result tests |
| Exactly three undergraduate enhancements | theme, AC, errors only | source and control inspection |
| Semantic labels, live updates | semantic operator labels and committed-state live region | semantics widget test; Android UI tree; TalkBack not performed |
| Formatter / analyzer / tests | lib, test, tool | format.log, analyze.log, tests.log |
| Build/install actual release | flutter build apk; adb install | release-build.log, release-install.log, release-smoke.json |
| Verified questions 01–06 | official same-edition HTML expanded details | assignment-source.html; implementation rationale |
| Two prompts × two actual services | supplied Gemini and ChatGPT responses, October 12, 2026 | COMPLETE: two comparisons in rationale; 30 tests passed; ai-comparison-tests.log |
| Reflection 06 Gemini/ChatGPT architecture comparison | exact separate prompt plus both supplied summaries | COMPLETE: critical comparison and source/test evidence in Reflection 06 |
| Accessible complete repository | isolated calculator project | repository-access evidence after publication |
| Three deliverables | submission directory | final file manifest and APK hash |
| Student review / policy / deadline | disclosure and pending checklist | student must confirm AI rules, personal wording, LMS timezone/folder |
