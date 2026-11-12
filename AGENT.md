# AGENT.md — AI Development Instructions

## A. Project Context

**Project Purpose:**
AeroNova AI — Virtual Travel Agent is a Flutter command-center application for AI-assisted trip planning, route recovery, booking management, offline trip kits, emergency assistance, translation, and scam verification. The app demonstrates mock data patterns, route recalculation logic, and UI patterns without a backend.

**Actual Technology Stack:**
- Framework: Flutter SDK ^3.14.0
- Language: Dart
- UI: Material Design 3 (useMaterial3: true)
- State Management: setState (local + lifted to MainAppShell)
- Navigation: BottomNavigationBar (5 items) + Drawer (9 items) + NavigationRail (wide, 5 items)
- Local Mock Services: MockDataService (static data), RouteRecoveryEngine (route recalculation)
- No backend, no database, no external APIs — all data is synthetic
- Color Scheme: Primary #147FE8, Secondary #FFF97316, Surface white, Background #F8FAFC
- Font: Roboto

**Main Application Modules:**
- `lib/main.dart` — AeroNovaApp (theme, ColorScheme), MainAppShell (tab index, state, callbacks, routing)
- `lib/models/travel_models.dart` — 14 data classes (Itinerary, Destination, Hotel, TransportOption, BookingItem, etc.)
- `lib/services/mock_data_service.dart` — Static methods: getDestinations, getHotels, getTransports, getInitialBookings, getEmergencyContacts, getPhrases, assessScam, getDefaultItinerary
- `lib/services/route_recovery_engine.dart` — Static engine: getInitialCheckpoints, getInitialRoutes, recalculate
- `lib/screens/` — 9 screens (Dashboard, AiTripPlanner, BookingDashboard, DestinationDiscovery, OfflineKit, EmergencyAssistance, Translation, ScamVerification, SmartRouteRecovery)

**Current Development Status:**
- Initial 1.0.0 release (2026-11-13)
- All 9 screens implemented and functional
- Mock data fully populated
- Route recovery engine with 3 scenarios
- No tests written yet
- No authentication or persistence

---

## B. Mandatory Rules Before Coding

1. **Read AGENT.md before starting any task.** This file is the primary entry point for all AI agents working on this project.
2. **Read relevant DESIGN.md, ARCHITECTURE.md and PROJECTFLOW.md sections.** Understand the design system, architecture, and workflows before making any modifications.
3. **Inspect the existing code before making modifications.** Read the actual source files that correspond to the area you're working on. Do not rely solely on documentation.
4. **Understand the existing implementation before proposing changes.** Verify that the feature you want to add does not already exist in a different form.
5. **Reuse existing components, functions and services whenever possible.** If a pattern already exists (e.g., `_buildActionCard`, category buttons, stepper circles), replicate that pattern rather than creating a new one.

---

## C. Coding Standards

- **Follow existing coding conventions:** Use the same indentation (2 spaces), naming styles, and widget patterns already in the codebase.
- **Use meaningful variable and function names:** `_currentTabIndex`, `onNavigateTab`, `_generateItinerary`, `recalculate` — match existing styles.
- **Write modular and reusable code:** Extract reusable widgets (cards, chips, buttons) rather than duplicating layout code.
- **Avoid unnecessary duplication:** If a widget pattern appears in multiple screens, extract it to a shared location or replicate the exact same pattern.
- **Keep functions focused:** Each function should do one thing (e.g., `_runAudit` only runs scam assessment, `_generateItinerary` only creates the itinerary object).
- **Handle errors properly:** Use `setState` for UI errors; use `ScaffoldMessenger.showSnackBar` for user-visible error messages.
- **Maintain proper separation of concerns:** Keep model data classes pure; keep service methods static; keep screen logic in the widget state.

---

## D. UI/UX Rules

- **Follow DESIGN.md:** Use the exact color values (`#147FE8`, `#FFF97316`, `#0F172A`, `#F8FAFC`), typography (Roboto, specified sizes), spacing (12/16/20/24px), and border radius (8/12/16/20/24px) definitions.
- **Maintain consistent colors, typography and spacing:** Never introduce new color values without updating DESIGN.md. If you must add a color, document it in DESIGN.md first.
- **Reuse existing components:** Reuse `_buildActionCard` from Dashboard, category button pattern from DestinationDiscovery, scenario chip pattern from SmartRouteRecovery. Do not invent new component styles without justification.
- **Ensure responsive behavior:** Respect the 768px breakpoint — BottomNavigationBar for narrow, NavigationRail for wide. Do not mix layout types across the breakpoint.
- **Avoid introducing inconsistent or generic UI designs:** All new components must match the existing design system. Do not use generic Material widgets with default colors if custom-styled alternatives exist.

---

## E. Architecture Rules

- **Follow ARCHITECTURE.md:** Do not introduce a new architecture or state management solution without strong justification. The project uses `setState`-based local state lifted to `MainAppShell` — do not switch to Provider, Riverpod, Bloc, etc.
- **Do not introduce a new architecture or state management solution without justification.** The current pattern is intentionally simple for a mock-data demo app.
- **Keep existing modules properly separated:** Screens import models and services; services are static; models are pure data. Do not merge these layers.
- **Avoid unnecessary dependencies:** The `pubspec.yaml` already has `material_ui: ^1.1.0` and `cupertino_icons: ^1.0.8`. Do not add new packages unless absolutely necessary — and never add a package just for UI styling that can be done with vanilla Flutter widgets.
- **Preserve existing API contracts:** The `MockDataService` and `RouteRecoveryEngine` APIs must not be changed in signature without updating all call sites. The `MainAppShell` callback signatures must remain compatible with all screens.

---

## F. Modification Rules

- **Never unnecessarily rewrite working code.** If a feature works, do not refactor it just to "clean it up." Changes must be justified by a new requirement or bug.
- **Do not delete existing functionality without explicit approval.** All 9 screens, all mock data methods, and all engine functionality must remain intact.
- **Do not modify unrelated modules.** Changes to `dashboard_screen.dart` must not break `ai_trip_planner_screen.dart` or vice versa.
- **Preserve existing API contracts unless changes are required.** If you must change a `MockDataService` method signature, update all 9 screens that call it.
- **Never hardcode credentials, API keys or secrets.** This project has no credentials, but this rule applies always.
- **Never expose sensitive environment variables.** No `.env` files or env var usage exists in this project.

---

## G. Testing Rules

- **Run relevant tests after modifications.** If you add or modify any screen or service, run `flutter test` to verify nothing is broken.
- **Check for build and compilation errors.** Run `flutter pub get` then `flutter analyze` and `flutter build` to verify compilation.
- **Verify affected functionality.** Manually verify the feature you modified works as expected (navigate to it, interact with it).
- **Do not claim a task is complete if it has not been verified.** Every task must have verification results documented.

---

## H. Documentation Rules

After every significant change:

- **Update CHANGELOG.md** under `## [Unreleased]` with the changes made. When ready, move the unreleased entry to a dated version (e.g., `## [1.0.1] - YYYY-MM-DD`).
- **Update ARCHITECTURE.md** if the architecture changes (new service, new data model, changed API).
- **Update PROJECTFLOW.md** if application workflows change (new user journey, added feature, removed module).
- **Update DESIGN.md** if UI/UX rules or design components change (new colors, new components, layout shifts).

---

## I. AI Agent Working Procedure

Follow this sequence for every development task:

1. **Understand the user's requirement.** What is the task? What feature is being added or modified?
2. **Inspect relevant source files.** Read the Dart files that correspond to the area of work. Look at similar implementations for patterns.
3. **Read related documentation.** Refer to AGENT.md, DESIGN.md, ARCHITECTURE.md, and PROJECTFLOW.md for conventions and constraints.
4. **Identify the files that need modification.** List the exact files that need changes, and what changes are needed in each.
5. **Explain the proposed implementation briefly.** Describe what you plan to do, which files you'll modify, and how you'll preserve existing behavior.
6. **Implement only the required changes.** Do not add unrelated features or refactor working code.
7. **Run relevant tests and checks.** `flutter test`, `flutter analyze`, `flutter build` — verify compilation and functionality.
8. **Update documentation.** Update CHANGELOG.md, ARCHITECTURE.md, PROJECTFLOW.md, DESIGN.md as needed per the documentation rules.
9. **Provide a summary of the modifications and verification results.** List what was changed, which files were modified, and the verification outcomes.

---

## 7. Final Requirements Recap

- **Create all five files in the project root:** ✓ Completed (DESIGN.md, ARCHITECTURE.md, PROJECTFLOW.md, CHANGELOG.md, AGENT.md)
- **Use clear Markdown formatting:** Headings, bullet points, tables, and Mermaid diagrams where useful.
- **Use actual file paths, class names, functions and API names** wherever possible.
- **Cross-reference related documentation files.**
- **Do not modify, delete or rename any existing source files.**
- **Do not install packages or change project configuration.**
- **Do not implement new features.**

---