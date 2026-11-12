# ARCHITECTURE.md — Technical Architecture

## A. Technology Stack

| Layer | Technology |
|-------|-----------|
| **Frontend Framework** | Flutter (SDK ^3.14.0) |
| **Language** | Dart |
| **UI Toolkit** | Material Design 3 (`useMaterial3: true`) |
| **State Management** | `setState` (local) + lifted state in `MainAppShell` |
| **Navigation** | BottomNavigationBar, NavigationRail, Drawer, RouteNamed (implicit) |
| **Local Mock Services** | `MockDataService` (static data methods), `RouteRecoveryEngine` (route recalculation) |
| **Persistence** | None (in-memory only; offline kit downloads to local storage but no DB) |
| **Dependency Injection** | None (direct imports, `const` constructors) |

### External Packages
- `cupertino_icons: ^1.0.8` — iOS-style cupertino icons
- `material_ui: ^1.1.0` — Material UI components (used in the project)

### Build & Tooling
- `flutter_lints: ^6.0.0` — lint rules activated via `analysis_options.yaml`
- `flutter_test` — testing framework (dev dependency)

### Platforms
- Mobile-first (iOS, Android implied)
- Material web implied but not explicitly configured
- No desktop-specific builds

---

## B. Project Structure

```
travel_agent_flutter/
├── .dart_tool/           — Flutter tooling metadata
├── .git/                 — Git version control
├── .idea/                — IntelliJ IDEA project config
├── android/              — Android native module (gradle, manifests)
├── build/                — Compiled output directory
├── test/                 — Dart test files
├── aeronova_travel.iml   — IntelliJ module file
├── analysis_options.yaml — Lint configuration
├── pubspec.lock          — Locked dependency versions
├── pubspec.yaml          — Project metadata & dependencies
├── README.md             — Project overview
├── main.dart             — Application entry point & app shell
└── lib/
    ├── main.dart         — Entry: AeroNovaApp → MainAppShell, theme, routing
    ├── models/           — Data models (Itinerary, Destination, Hotel, etc.)
    │   └── travel_models.dart
    ├── services/         — Mock data & route recovery engines
    │   ├── mock_data_service.dart
    │   └── route_recovery_engine.dart
    └── screens/          — UI screens (9 total)
        ├── ai_trip_planner_screen.dart
        ├── booking_dashboard_screen.dart
        ├── dashboard_screen.dart
        ├── destination_discovery_screen.dart
        ├── emergency_assistance_screen.dart
        ├── offline_kit_screen.dart
        ├── scam_verification_screen.dart
        ├── smart_route_recovery_screen.dart
        └── translation_screen.dart
```

### Directory Responsibilities

| Directory | Responsibility |
|-----------|---------------|
| `lib/models/` | Dart classes representing data structures (itineraries, destinations, bookings, etc.). Pure Dart classes with no behavior beyond data holding. |
| `lib/services/` | Static service classes providing mock data (`MockDataService`) and route recalculation logic (`RouteRecoveryEngine`). No external API calls — all data is synthetic. |
| `lib/screens/` | Flutter `StatelessWidget` / `StatefulWidget` UI components. Each screen is self-contained with its own logic; navigation is coordinated by `MainAppShell`. |
| `lib/main.dart` | Application bootstrap: `AeroNovaApp` (Theme, ColorScheme), `MainAppShell` (bottom nav / drawer / tab management), widget routing logic. |
| `test/` | Dart test files (structure not deeply inspected, exists as standard Flutter project). |
| `android/` | Native Android build infrastructure. |

### Module Connections

- **`main.dart`** is the root: `AeroNovaApp` provides the `ThemeData` and sets `home: MainAppShell()`. `MainAppShell` manages the tab index state, initializes mock data via `MockDataService`, and renders the `_buildScreen(index)` + navigation UI (bottom nav, drawer, navigation rail).

- **`MainAppShell`** → **Screens**: Each screen is instantiated via `_buildScreen(index)` with required dependencies (`activeItinerary`, `onNavigateTab`, `userBookings`, etc.). Screens communicate back to the shell via callback functions.

- **Screens** → **Models**: Import `travel_models.dart` and use the model classes (`Itinerary`, `Destination`, `Hotel`, `BookingItem`, etc.) directly as data structures.

- **Screens** → **Services**: Import and call `MockDataService` static methods (`getDestinations()`, `getDefaultItinerary()`, `getHotels()`, `getTransports()`, `getEmergencyContacts()`, `getPhrases()`, `assessScam()`) and `RouteRecoveryEngine` (`recalculate()`).

- **No backend/DB**: All data is in-memory / static. `MockDataService` is the sole data source. No persistence layer, no API layer, no authentication server.

---

## C. Architecture Overview

The project follows a **client-side MVC-like architecture** where:

- **Model**: `travel_models.dart` — data classes (Itinerary, Destination, Hotel, TransportOption, BookingItem, etc.)
- **View**: Flutter UI screens in `lib/screens/`
- **Controller/Coordinator**: `MainAppShell` in `lib/main.dart` — manages global state (tab index, active itinerary, user bookings, emergency contacts) and delegates to screens

### Mermaid Diagram: System Architecture

```mermaid
graph TD
    A[User] -->|Interaction| B[MainAppShell]
    B -->|State & Navigation| C[DashboardScreen]
    B -->|State & Navigation| D[AiTripPlannerScreen]
    B -->|State & Navigation| E[BookingDashboardScreen]
    B -->|State & Navigation| F[DestinationDiscoveryScreen]
    B -->|State & Navigation| G[OfflineKitScreen]
    B -->|State & Navigation| H[EmergencyAssistanceScreen]
    B -->|State & Navigation| I[TranslationScreen]
    B -->|State & Navigation| J[ScamVerificationScreen]
    B -->|State & Navigation| K[SmartRouteRecoveryScreen]
    
    C -->|Uses| M[travel_models.dart]
    C -->|Calls| N[MockDataService]
    
    D -->|Uses| M
    D -->|Calls| N
    
    E -->|Uses| M
    E -->|Calls| N
    
    F -->|Uses| M
    F -->|Calls| N
    
    G -->|Uses| M
    
    H -->|Uses| M
    H -->|Calls| N
    
    I -->|Calls| N
    
    J -->|Uses| M
    J -->|Calls| N
    
    K -->|Uses| M
    K -->|Calls| RouteRecoveryEngine
    
    N -->|Provides| Static data (destinations, itineraries, hotels, transports, contacts, phrases, scam assessments)
    RouteRecoveryEngine -->|Recalculates| Route possibilities
```

### Key Architectural Decisions

1. **No Separate Backend**: All data is synthetic/mock. The app is a client-side demonstration of UI patterns, state management, and route logic.

2. **Single Source of Truth in MainAppShell**: Tab index, active itinerary, user bookings, and emergency contacts live in `_MainAppShellState`. Screens receive these as `final` fields plus callbacks.

3. **Flat Navigation Model**: No deep routing. All 9 screens are reachable from the bottom navigation bar (5 items) or drawer (9 items). The `MainAppShell` maps index → widget.

4. **Stateless Screen Factories**: Most screens are `StatelessWidget` with internal `State` objects. Only `BookingDashboardScreen` uses `TabController`.

5. **No External APIs**: All data originates from `MockDataService`. `RouteRecoveryEngine` operates on internally generated checkpoint/route data.

---

## D. Frontend Architecture

### Pages and Screens (9 total)

| Screen | Key Widgets | State | Callbacks |
|--------|-----------|-------|-----------|
| `DashboardScreen` | Action cards, stepper, budget progress, destination grid | `onNavigateTab(int)` | — |
| `AiTripPlannerScreen` | Prompt box, form parameters, generated itinerary display | `_isGenerating`, `_selectedDayIndex`, `_generateItinerary()` | `onSaveOffline(Itinerary)` |
| `BookingDashboardScreen` | TabBar (3 tabs), hotel/train/ride lists, ElevatedButton bookings | `_tabController` | `onBookingCreated(BookingItem)` |
| `DestinationDiscoveryScreen` | Category filters, destination grid, "Add to Planner" | `_selectedCategory`, `_searchQuery` | `onAddDestination(Destination)` |
| `OfflineKitScreen` | Banner, download button, voucher list, emergency contacts | `_isDownloading` | — |
| `EmergencyAssistanceScreen` | SOS banner, speed dials, emergency contacts list | `_sosActive`, `_countdown` | `_triggerSos()` |
| `TranslationScreen` | Language selector, text translator, phrasebook | `_selectedLang`, `_customTranslation` | `_translateCustom()` |
| `ScamVerificationScreen` | Audit form, risk score display, indicators | `_assessment`, `_runAudit()` | — |
| `SmartRouteRecoveryScreen` | Checkpoint simulator, delay slider, scenario chips, route list | `_selectedCheckpointId`, `_delayMinutes` | `_onRouteRebooked(RoutePossibility)` |

### State Management

- **Local state**: Each screen manages its own UI state (`setState` within the widget tree).
- **Global shell state**: `_MainAppShellState` holds `activeItinerary`, `_userBookings`, `_emergencyContacts`, and `_currentTabIndex`.
- **Lifting state**: Callbacks (`onNavigateTab`, `onBookingCreated`, `onSaveOffline`, `onAddDestination`, `onRebooked`) lift state from screens back to the shell.

### Routing

- **Index-based**: `MainAppShell` uses `_currentTabIndex` (0-8) to determine which screen is displayed.
- **Drawer navigation**: Tapping drawer items sets `_currentTabIndex` and closes the drawer.
- **Bottom nav**: Tapping items sets `_currentTabIndex`.
- **No URL routing**: No `go_route` or `auto_route`. Pure index mapping.

### Services

- `MockDataService` — static methods returning hardcoded data:
  - `getDestinations()` → `List<Destination>`
  - `getHotels()` → `List<Hotel>`
  - `getTransports()` → `List<TransportOption>`
  - `getInitialBookings()` → `List<BookingItem>`
  - `getEmergencyContacts()` → `List<EmergencyContact>`
  - `getPhrases(String lang)` → `List<TravelPhrase>`
  - `assessScam(String text, String method)` → `ScamCheckAssessment`
  - `getDefaultItinerary()` → `Itinerary`

- `RouteRecoveryEngine` — static engine for route recalculation:
  - `getInitialCheckpoints()` → `List<CheckpointStatus>`
  - `getInitialRoutes()` → `List<RoutePossibility>`
  - `recalculate({required String activeCheckpointId, required int delayMinutes})` → `Map<String, dynamic>`

### Models

- `travel_models.dart` defines 14 data classes:
  - `Activity`, `DayPlan`, `Itinerary`, `Destination`, `Hotel`, `TransportOption`, `BookingItem`
  - `JourneyLeg`, `RoutePossibility`, `CheckpointStatus`
  - `EmergencyContact`, `TravelPhrase`, `ScamRiskIndicator`, `ScamCheckAssessment`

### Data Handling

- Data flows from `MockDataService` → screens → UI.
- User interactions trigger callbacks → `MainAppShell` state updates → `setState` re-renders affected screen.
- No async API calls in the current implementation (all `Future.delayed` simulations only).
- `Itinerary` objects are created inline in screen logic or via `MockDataService.getDefaultItinerary()`.

---

## E. Backend Architecture

**Note**: This project has no backend server, no database, and no external API integrations. All processing occurs client-side in Dart.

### Server Structure

- None. The application runs entirely on the client (mobile/device).

### Models

- Same as frontend models (`travel_models.dart`) — used only for in-memory data representation.

### Authentication and Authorization

- **None implemented**. The application does not require user authentication. All users have access to the same mock data.

### Middleware

- None. No request/response pipeline exists.

---

## F. Database Architecture

**Note**: This project has no database. Data is ephemeral and held in memory.

### Collections / Tables

| Collection | Fields (Key Examples) |
|-----------|----------------------|
| **Destinations** | id, name, country, region, category, rating, reviewCount, imageUrl, description, highlights, topAttractions, localExperiences, recommendedRestaurants, averageDailyBudget, currency, bestSeason |
| **Hotels** | id, name, location, city, rating, reviewCount, pricePerNight, currency, imageUrl, facilities, distanceFromAttractions, address, availableRooms, cancellationPolicy |
| **TransportOptions** | id, type, provider, routeCode, from, to, departureTime, arrivalTime, duration, price, currency, rating, seatsAvailable, vehicleType, status |
| **BookingItems** | id, type, title, provider, referenceNumber, destination, price, currency, status, voucherNumber, details, isOfflineAvailable |
| **CheckpointStatus** | id, name, code, sequence, scheduledArrival, scheduledDeparture, actualArrival, delayMinutes, minTransferTimeMinutes, status, notes |
| **RoutePossibility** | id, name, pathDescription, checkpoints, legs, departureTime, estimatedArrivalTime, totalDurationMinutes, totalWaitingMinutes, totalCost, isPrimary, isFeasible, feasibilityReason, feasibilityRisk, recommendedAction |
| **Itinerary** | id, title, destination, startLocation, startDate, endDate, durationDays, durationNights, travellers, budgetTier, tags, summary, heroImage, days, estimatedTotalCost, currency, createdAt, isSavedOffline |
| **EmergencyContact** | id, category, name, phone, address, distance, openHours, is24x7 |
| **TravelPhrase** | id, category, language, english, translated, phonetic |
| **ScamRiskIndicator** | label, type, description |
| **ScamCheckAssessment** | riskScore, riskLevel, verdict, indicators, recommendations, disclaimer, evaluatedAt |

### Relationships

- **Itinerary** 1:N **DayPlan** (via `days` list)
- **DayPlan** 1:N **Activity** (via `activities` list)
- **Itinerary** 1:1 **Hotel** (via booking)
- **Itinerary** 1:N **BookingItem** (via user bookings)
- **RoutePossibility** 1:N **JourneyLeg** (via `legs` list)
- **CheckpointStatus** has no bidirectional relationships in current code; used linearly in `RouteRecoveryEngine.recalculate()`

### Indexes

- None. Data structures are lists; lookup is sequential (`firstWhere`, `where`).

### Data Ownership and Access Patterns

- **Read-dominant**: Screens read from `MockDataService` static methods.
- **Write via interaction**: User taps → callbacks → `MainAppShell` state update → `setState`.
- **No concurrent writes**: Single-threaded Flutter event loop; no race conditions in current implementation.
- **Data is project-owned**: No external data sources; all synthetic.

---

## G. API Architecture

**Note**: This project has no external HTTP APIs. All data is provided via local Dart static methods.

### Internal "API" — MockDataService

| Method | Return Type | Description |
|--------|------------|-------------|
| `getDestinations()` | `List<Destination>` | All destination objects with image URLs, highlights, budgets |
| `getHotels()` | `List<Hotel>` | Hotel objects with facilities, pricing, distances |
| `getTransports()` | `List<TransportOption>` | Transport options (train, Ola, Uber) with routes and pricing |
| `getInitialBookings()` | `List<BookingItem>` | Pre-seeded bookings for the default itinerary |
| `getEmergencyContacts()` | `List<EmergencyContact>` | Emergency contact objects for Jodhpur region |
| `getPhrases(String lang)` | `List<TravelPhrase>` | Language-specific phrase pairs (Italian, Hindi) |
| `assessScam(String text, String method)` | `ScamCheckAssessment` | Heuristic scam risk scoring based on keyword patterns |
| `getDefaultItinerary()` | `Itinerary` | Default 5-day Jodhpur itinerary used on app launch |

### Internal "API" — RouteRecoveryEngine

| Method | Parameters | Return Type | Description |
|--------|-----------|-------------|-------------|
| `recalculate` | `activeCheckpointId: String`, `delayMinutes: int`, `customArrivalTimeStr: String?` | `Map<String, dynamic>` | Recalculates feasible routes given a checkpoint delay; promotes primary/alternative routes, generates alerts |
| `getInitialCheckpoints` | None | `List<CheckpointStatus>` | Initial checkpoint status list (Home → A → B → Jodhpur) |
| `getInitialRoutes` | None | `List<RoutePossibility>` | Three route options (primary, direct bypass, southern corridor) |

### Request/Response Patterns

- All "requests" are synchronous method calls returning pre-built Dart objects.
- No JSON serialization/deserialization in the current code path.
- No network errors to handle (all data is local).
- Scam assessment is the only "logic" endpoint; it computes a risk score based on keyword matching.

---

## H. Security

### Authentication

- **Not implemented**. The application has no user accounts, login screens, or token-based authentication. Any user can access all features immediately.

### Authorization

- **Not implemented**. All features are available to all users without restriction.

### Validation

- **Input validation present in scam verification**: The `assessScam` method in `MockDataService` validates text input against keyword patterns (crypto, wire transfer, urgency, TLDs).
- **Form field validation**: Minimal — `TextField` with `maxLines` constraints; no custom validator functions.
- **Empty state handling**: Empty inputs result in no-op UI changes (e.g., translate with empty query returns silently).

### Environment Variables

- **None used**. No `dotenv`, no `Platform.is` checks based on env vars. All configuration is hardcoded in `pubspec.yaml` and `main.dart`.

### Data Protection

- **No sensitive data** stored or transmitted. The app contains no API keys, passwords, or user secrets.
- **Offline kit** downloads data to local device storage but does not encrypt it; the feature is designed for zero-connectivity access, not data security.
- **No network traffic** beyond what Flutter Material widgets implicitly do (no `http` client configured).

### Security Summary

| Aspect | Status |
|--------|--------|
| Authentication | Not present |
| Authorization | Not present |
| Input Validation | Partial (scam only) |
| Environment Variables | None |
| Data Encryption | None (offline data is plain) |
| Network Exposure | None (no HTTP client) |

---

## I. Data Flow

### User Interface → Backend → Database → Back → UI

Since there is no backend or database, the data flow is **UI ↔ Shell ↔ Mock Services**:

```
1. User taps bottom navigation item
   │
   ▼
2. MainAppShell sets _currentTabIndex = index
   │
   ▼
3. setState rebuilds body with _buildScreen(index)
   │
   ▼
4. Screen widget builds UI using data from:
   - MockDataService static methods (getDestinations, getDefaultItinerary, etc.)
   - Local widget state (text controllers, booleans, selections)
   - Callback functions from parent (onNavigateTab, onSaveOffline, etc.)
   │
   ▼
5. User interacts with screen (types text, taps buttons, adjusts sliders)
   │
   ▼
6. Screen calls setState or calls callback → MainAppShell state updates
   │
   ▼
7. setState triggers widget rebuild with new data
   │
   ▼
8. Loop continues (steps 1-7) until user exits or navigates differently
```

### Example Flows

**Flow: Generate AI Itinerary**
1. User types prompt or adjusts parameters on `AiTripPlannerScreen`
2. User taps "Generate AI Itinerary"
3. `_generateItinerary()` creates a new `Itinerary` object with hardcoded day plans
4. `setState` updates `_generatedItinerary` → UI displays generated itinerary
5. User taps "Save Offline" → `widget.onSaveOffline(_generatedItinerary)` → shell stores it

**Flow: Smart Route Recovery**
1. User navigates to `SmartRouteRecoveryScreen` (tab 1 or drawer item 2)
2. Engine recalculates routes via `RouteRecoveryEngine.recalculate(activeCheckpointId, delayMinutes)`
3. UI displays checkpoint status, alert box, and route possibilities
4. User selects a route and taps "Confirm & Issue Vouchers"
5. `widget.onRebooked(route)` → shell updates bookings → snackbar confirms

**Flow: Scam Verification**
1. User pastes suspicious text on `ScamVerificationScreen`
2. User changes payment method if needed
3. Taps "Audit Listing"
4. `_runAudit()` → `MockDataService.assessScam(text, method)` → computes risk score
5. `setState` displays risk score, verdict, risk signals, and disclaimer

**Flow: Offline Kit Download**
1. User navigates to `OfflineKitScreen`
2. Taps "Download Active Trip for Offline"
3. `_downloadTrip()` → `Future.delayed` simulation → snackbar "Trip Kit Packaged"
4. In a real app, this would package data into a local file; currently just a UI simulation.

---