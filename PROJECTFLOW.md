# PROJECTFLOW.md — Complete Application Workflow

## A. Application Overview

**AeroNova AI — Virtual Travel Agent** is a Flutter-based mobile application that functions as an autonomous travel command center. The app provides:

- **Trip planning** via conversational AI
- **Route recovery** with autonomous re-routing logic
- **Booking management** for hotels, trains, flights, and local cabs
- **Offline access** to vouchers, contacts, and trip data
- **Emergency assistance** with SOS activation
- **Language translation** with situational phrasebook
- **Scam verification** for suspicious travel communications

**Primary User Interaction Mode**: Tab-based navigation (5 primary tabs) with a slide-out drawer for all 9 screens. The app is designed as a "command center" where the Dashboard is the default home, and users can navigate to any feature via bottom navigation or drawer.

**Data State**: All data is synthetic/mock. The app simulates travel scenarios without connecting to external APIs or databases.

---

## B. User Journey

### Launch Sequence

1. **App starts** → `AeroNovaApp` builds `MaterialApp` with custom `ThemeData` (primary: `#147FE8`, secondary: `#FFF97316`, surface: white, background: `#F8FAFC`, font: Roboto)
2. `home: MainAppShell()` initializes with `_currentTabIndex = 0`
3. `MainAppShell.initState()` calls `MockDataService.getDefaultItinerary()`, `getInitialBookings()`, `getEmergencyContacts()`
4. **Home screen appears**: `DashboardScreen` with welcome banner, active trip status, quick actions, budget overview, and trending destinations

### From Launch to Main Features

| Path | Screens Visited | Primary Action |
|------|----------------|----------------|
| **Default** | Dashboard → (any tab) | View trip overview, use quick actions |
| **Plan a Trip** | Dashboard → AiTripPlannerScreen → (generate → save offline) | Create new itinerary via AI |
| **Manage Bookings** | Dashboard → BookingDashboardScreen → (select tab → book) | Reserve hotels, trains, flights, cabs |
| **Explore Destinations** | Dashboard → DestinationDiscoveryScreen → (select destination → add to planner) | Browse and select travel destinations |
| **Recovery Scenario** | Dashboard → SmartRouteRecoveryScreen (tab 1 or drawer 2) | Simulate delay, get route recommendations |
| **Offline Preparation** | Dashboard → OfflineKitScreen | Download trip kit for offline access |
| **Emergency Assistance** | Dashboard → drawer → EmergencyAssistanceScreen | Activate SOS, view emergency contacts |
| **Translate Phrases** | Dashboard → drawer → TranslationScreen | Translate text, browse phrasebook |
| **Verify Scam** | Dashboard → drawer → ScamVerificationScreen | Audit suspicious communications |

### Authentication State (Not Applicable)

- No login screen. App always starts at Dashboard with mock data pre-loaded.
- User context: "Rishi" is hardcoded in the welcome banner (`Welcome back, Rishi`).

---

## C. Feature Workflows

### 1. Smart Route Recovery Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User navigates to SmartRouteRecoveryScreen | — | — | Route recovery engine screen |
| 2 | User selects checkpoint + adjusts delay slider | `RouteRecoveryEngine.recalculate()` | Checkpoint `actualArrival`, `delayMinutes`, `status` | Live alert box shows feasibility status |
| 3 | Engine recalculates routes based on delay | `RouteRecoveryEngine.recalculate()` | Route `isPrimary`, `isFeasible`, `feasibilityReason`, `recommendedAction` | Route list updates with feasibility notes |
| 4 | User taps scenario chip (e.g., +45m late) | Sets `_delayMinutes = 45`, triggers recalculation | Updated delay state | Scenario chip becomes active; routes update |
| 5 | User taps "Confirm & Issue Vouchers" on feasible route | `widget.onRebooked(route)` → shell `_onRouteRebooked` | New `BookingItem` inserted into `_userBookings` | Snackbar: "Route confirmed: X. Digital vouchers issued!" |
| 6 | If missed connection: engine promotes alternative route | Automatic within `recalculate()` | Route priorities shift (1° → 2° → 3°) | Alert: "Option 1 disqualified. Option 2 promoted!" |

**Errors / Edge Cases**:
- Delay > 110m: Both primary and secondary routes missed → Option 3 (emergency corridor) promoted
- No feasible routes: All `isFeasible = false`, user must manually rebook

---

### 2. AI Trip Planning Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User opens AiTripPlannerScreen or taps "AI Trip Planner" from dashboard | — | — | Prompt box with default vision text |
| 2 | User types/customizes parameters (location, budget, nights, interests) | — | User preferences in local state | Form fields update |
| 3 | User taps "Generate AI Itinerary" | `_generateItinerary()` → `Future.delayed(900ms)` → creates `Itinerary` object | New `Itinerary` with day plans, activities, hero image, estimated cost | Loading state → itinerary displayed |
| 4 | User reviews generated itinerary (day tabs, activity cards) | — | `_generatedItinerary` in state | UI shows hero image, day tabs, activity list with costs |
| 5 | User taps "Save Offline" | `widget.onSaveOffline(itinerary)` → `_onSaveOffline(itin)` in shell | `_activeItinerary.isSavedOffline = true` | Snackbar: "Itinerary saved to Offline Trip Kit!" |
| 6 | User may adjust interests via filter chips | `_selectedInterests` set state | Interest tags added to itinerary tags list | Chips toggle selected/unchecked |

**Errors / Edge Cases**:
- Empty prompt: `_translateCustom()` returns early if query is empty
- No interests selected: Itinerary still generates with default tags `[_budgetTier.toUpperCase(), 'AI GENERATED']`

---

### 3. Booking Management Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User navigates to BookingDashboardScreen | — | — | Booking dashboard with tabbed interface |
| 2 | User selects tab: Hotels & Stays / Trains & Flights / Ola / Uber Cabs | TabBar state | — | Relevant tab content loads |
| 3 | User taps "Book Room" / "Book Ticket" / "Dispatch Ride" on an item | Creates new `BookingItem` → `widget.onBookingCreated(booking)` | New `BookingItem` inserted at `_userBookings[0]` | Snackbar confirmation + booking appears in list |
| 4 | Booking item appears in "Active Vouchers Issued" counter | Shell `setState` | `_userBookings.length` increments | Counter updates at top of dashboard |
| 5 | User views bookings in OfflineKitScreen | Reads `_userBookings` from shell | All bookings listed with vouchers | Vouchers displayed as "OFFLINE VALID" cards |

**Errors / Edge Cases**:
- No bookings: Counter shows "0 Active Vouchers Issued"; voucher list is empty
- Dispatch ride: Shows snackbar "Dispatched X! Driver arriving in 3 mins." (no actual driver)

---

### 4. Destination Discovery Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User navigates to DestinationDiscoveryScreen | — | — | Grid of destination cards |
| 2 | User filters by category (All / Popular / Hidden Gems) | `_selectedCategory` set state | Category filter applied | Grid filters to match category |
| 3 | User enters search query (extension via `FilterExp`) | `_searchQuery` set state | Query filter applied | Grid filters by name/country match |
| 4 | User taps "Add to Planner" on a destination | `widget.onAddDestination(dest)` → shell `_currentTabIndex = 2` | Destination passed to AI planner | Snackbar: "Added X to Itinerary Planner!" → navigates to tab 2 |
| 5 | User selects destination → planner | — | — | AiTripPlannerScreen opens with destination context |

**Errors / Edge Cases**:
- No destinations match filter: Grid is empty (ListView with 0 items)

---

### 5. Emergency SOS Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User navigates to EmergencyAssistanceScreen or taps from drawer | — | — | SOS banner + speed dials |
| 2 | User taps "ACTIVATE SOS ALERT" | `_triggerSos()` → `setState: _sosActive = true, _countdown = 5` → `Future.doWhile` countdown | `_sosActive`, `_countdown` decrementing every second | SOS banner shows "BROADCASTING IN Ns · 112 ALERT" |
| 3 | Countdown runs 5 → 0 | `Future.delayed(const Duration(seconds: 1))` | Countdown continues while `_sosActive = true` | Visual countdown on SOS banner |
| 4 | User taps "CANCEL" on SOS banner | `setState: _sosActive = false` | Countdown stops immediately | SOS banner reverts to "ACTIVATE SOS ALERT" button |
| 5 | SOS inactive: normal screen resumes | — | `_sosActive = false` | UI returns to normal |
| 6 | Call speed dials (112, 108, 1363) | `ScaffoldMessenger.showSnackBar` | Simulated call message | Snackbar: "Simulated Call dispatched to: +91 291 2740741" |

**Errors / Edge Cases**:
- Countdown reaches 0 while `_sosActive = true`: `Future.doWhile` stops (condition `_countdown > 0` fails)
- No real telephony: All calls are simulated via Snackbar feedback

---

### 6. Translation Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User navigates to TranslationScreen or taps from drawer | — | — | Language selector + phrasebook |
| 2 | User selects language (Italian / Hindi) | `_selectedLang` set state | Language preference | Phrasebook updates to selected language |
| 3 | User types custom text in translator | `_customController.text` | User input text | — |
| 4 | User taps "Translate" | `_translateCustom()` → sets `_customTranslation` based on `_selectedLang` | Translation result | Text displayed in `#EFF6FF` card below input |
| 5 | User taps phone icon | `ScaffoldMessenger.showSnackBar` | "Pronouncing: X" | Snackbar with pronunciation feedback |
| 6 | User browses phrasebook list | `MockDataService.getPhrases(_selectedLang)` | Language-specific phrases | List of English/translated/phonetic phrases |

**Errors / Edge Cases**:
- Empty query: `_translateCustom()` returns early; no translation card shown
- Language switch: Previous translation cleared, phrasebook reloaded

---

### 7. Scam Verification Workflow

| Step | Action | Backend/Service | Data Stored | User Output |
|------|--------|----------------|-------------|-------------|
| 1 | User navigates to ScamVerificationScreen or taps from drawer | — | — | Audit form present |
| 2 | User pastes suspicious communication text | `_textController.text` | User input | — |
| 3 | User selects payment method | `_paymentMethod` set state | Payment method string | — |
| 4 | User taps "Audit Listing" | `_runAudit()` → `MockDataService.assessScam(text, method)` | — | Risk score, verdict, indicators, recommendations appear |
| 5 | Assessment displayed: riskScore/100, riskLevel badge, verdict text | `ScamCheckAssessment` object in state | — | Colored badges: CRITICAL HIGH MODERATE LOW |
| 6 | User reads risk signals and disclaimer | `_assessment!.indicators`, `_assessment!.disclaimer` | — | Educational feedback on potential scam markers |

**Errors / Edge Cases**:
- Text with no risk indicators: Score defaults to 10, labeled "LOW RISK", safe indicator added
- All risk flags triggered: Score can reach 99, labeled "CRITICAL RISK"

---

## D. Navigation Flow

### Mermaid Flowchart: Application Navigation

```mermaid
flowchart TD
    A[App Launch] --> B[DashboardScreen (Tab 0)]
    
    %% Bottom Navigation Bar
    B -->|Tab 1| C[SmartRouteRecoveryScreen]
    B -->|Tab 2| D[AiTripPlannerScreen]
    B -->|Tab 3| E[DestinationDiscoveryScreen]
    B -->|Tab 4| F[OfflineKitScreen]
    B -->|Tab 5| G[BookingDashboardScreen]
    
    %% Drawer (9 items)
    B -->|Drawer Item| H[EmergencyAssistanceScreen (6)]
    B -->|Drawer Item| I[TranslationScreen (7)]
    B -->|Drawer Item| J[ScamVerificationScreen (8)]
    
    %% Return from all screens
    C -->|Bottom Nav/ Drawer| B
    D -->|Bottom Nav/ Drawer| B
    E -->|Bottom Nav/ Drawer| B
    F -->|Bottom Nav/ Drawer| B
    G -->|Bottom Nav/ Drawer| B
    H -->|Drawer| B
    I -->|Drawer| B
    J -->|Drawer| B
    
    %% Wide screen NavigationRail (within Dashboard only)
    B -->|Width >= 768px| K[NavigationRail (Tabs 0-4)]
    K -->|Select dest| B
    
    %% AI Itinerary save flow
    D -->|Save Offline| L[MainAppShell stores activeItinerary]
    L -->|Snackbar| M[User feedback]
    
    %% Route recovery rebook flow
    C -->|Confirm Rebook| N[widget.onRebouted → shell]
    N -->|Snackbar| M
    
    %% Booking flow
    G -->|Book Created| O[_userBookings updated]
    O -->|Snackbar| M
    
    %% Emergency SOS flow
    H -->|SOS Trigger| P[_sosActive countdown]
    P -->|Cancel| B
    P -->|Countdown end| B
```

### Entry Point → Main Modules Navigation

```
App Launch
    ↓
DashboardScreen (Tab 0 — Home)
    │
    ├──► BottomNavigationBar (5 tabs)
    │   ├── Tab 1: Smart Route Recovery
    │   ├── Tab 2: AI Trip Planner
    │   ├── Tab 3: Explore Destinations
    │   ├── Tab 4: Offline Trip Kit
    │   └── Tab 5: Bookings & Vouchers
    │
    └──► Drawer (9 items)
        ├── Dashboard (0) — selected
        ├── Smart Route Recovery (1) — signature
        ├── Plan a Trip (AI) (2)
        ├── Explore Destinations (3)
        ├── Offline Travel Kit (4)
        ├── Travel Bookings (5)
        ├── Emergency SOS Assistance (6)
        ├── Translation Assistant (7)
        └── Travel Scam Verification (8)
```

### Screen Transition Summary

| From → To | Trigger | Navigation Method |
|-----------|---------|-------------------|
| Dashboard → Any screen | Bottom nav tap | `_currentTabIndex = index; setState` |
| Dashboard → Any screen | Drawer item tap | `_currentTabIndex = index; Navigator.pop(context); setState` |
| Any screen → Dashboard | System back button / drawer close | `Navigator.pop(context)` |
| AiTripPlannerScreen → Dashboard | "Save Offline" button | `widget.onSaveOffline(itinerary)` + `Navigator.pop` |
| SmartRouteRecoveryScreen → Dashboard | "Confirm & Issue Vouchers" | `widget.onRebooked(route)` + `Navigator.pop` |
| BookingDashboardScreen → Dashboard | Booking created | `widget.onBookingCreated(booking)` + `Navigator.pop` |
| DestinationDiscoveryScreen → Dashboard | "Add to Planner" | `widget.onAddDestination(dest)` + `Navigator.pop` + tab reflow |

---

## E. System Workflow

### Frontend → Backend → Database → External APIs → Back → Front

**Since this project has no backend, database, or external APIs, the system workflow is:**

```
User Interaction
    │
    ▼
Flutter Widget Tree (UI)
    │
    ├──► setState (local)
    │   │
    │   ▼
    │ MainAppShell (global state: tab index, active itinerary, bookings, contacts)
    │
    │   ├──► MockDataService (static methods — all synthetic data)
    │   │   • getDestinations(), getHotels(), getTransports()
    │   │   • getInitialBookings(), getEmergencyContacts()
    │   │   • getPhrases(), assessScam(), getDefaultItinerary()
    │   │
    │   └──► RouteRecoveryEngine (route recalculation logic)
    │       • getInitialCheckpoints(), getInitialRoutes()
    │       • recalculate({activeCheckpointId, delayMinutes})
    │
    ▼
    setState triggers UI rebuild
    │
    ▼
User sees updated screen
```

### Interaction Diagrams

**1. Data Flow: Itinerary Generation**
```
User taps Generate AI Itinerary
    ↓
_AiTripPlannerScreenState._generateItinerary()
    ↓
creates Itinerary object with DayPlan(s) → Activity(s)
    ↓
setState → _generatedItinerary updated
    ↓
UI rebuilds: hero image, day tabs, activity cards displayed
```

**2. Data Flow: Route Recalculation**
```
User adjusts delay slider / selects checkpoint
    ↓
_SmartRouteRecoveryScreenState: _delayMinutes / _selectedCheckpointId updated
    ↓
RouteRecoveryEngine.recalculate(activeCheckpointId, delayMinutes)
    ↓
engine mutates checkpoint status + route feasibility
    ↓
Map<String, dynamic> returned: checkpoints, routes, alertMessage, alertSeverity, hasMissedConnection
    ↓
UI updates: alert box color/text, route list with feasibility notes, stepper cards
```

**3. Data Flow: Scam Assessment**
```
User pastes text + selects payment method
    ↓
_runAudit() → MockDataService.assessScam(text, method)
    ↓
computes riskScore (20-base + keyword penalties) + riskLevel + verdict + indicators + recommendations
    ↓
setState → _assessment updated
    ↓
UI: risk score dial, verdict badge, risk signals list, disclaimer shown
```

**4. Data Flow: Offline Kit Download**
```
User taps "Download Active Trip for Offline"
    ↓
_OfflineKitScreenState._downloadTrip()
    ↓
Future.delayed(const Duration(milliseconds: 800))
    ↓
setState → _isDownloading = false
    ↓
ScaffoldMessenger.showSnackBar: "Trip Kit Packaged & Verified for Offline Access!"
```

---

## F. Important Scenarios

### Normal Usage Scenarios

| Scenario | Description | Outcome |
|----------|-------------|---------|
| **Launch and view dashboard** | App starts, default Jodhpur itinerary loads | Welcome banner shows "AeroNova AI 2.0 · Virtual Travel Agent", active corridor info displayed |
| **Navigate via bottom tabs** | User taps tab 2 (AI Planner) | AiTripPlannerScreen replaces dashboard; prompt box visible |
| **Book a hotel** | User taps "Book Room" on a hotel card | New BookingItem created, snackbar confirms, voucher count increments |
| **Filter destinations** | User taps "Hidden Gems" category | Grid filters to show only hidden-gem destinations |
| **Adjust delay in route recovery** | User slides delay to +30m | Alert box updates, feasibility reassessed, possible route promotion |
| **Save itinerary offline** | User taps "Save Offline" on AI planner | Itinerary marked isSavedOffline=true; snackbar confirms |

### Invalid Input Scenarios

| Scenario | Description | Outcome |
|----------|-------------|---------|
| **Empty prompt in AI planner** | User taps Generate without typing | `_generateItinerary()` still runs with default prompt text; no error |
| **Empty search in destination discovery** | No query entered, category filter active | Grid filters by category only; all items in that category shown |
| **Delay slider at max (140m)** | User sets extreme delay | All primary/secondary routes marked infeasible; Option 3 (emergency) promoted; alert shows "EMERGENCY" |
| **No interests selected** | User generates itinerary without selecting interest chips | Itinerary generates with default tags `['MODERATE', 'AI GENERATED']` only |
| **Empty scam text** | User audits without pasting text | `assessScam` returns base score 10 + "Standard Booking Disclosures Present" → LOW RISK |

### Network Failure Scenarios

| Scenario | Description | Outcome |
|----------|-------------|---------|
| **No network dependency** | All data is mock/local | No network errors possible. All operations complete instantly or via artificial `Future.delayed` delays. |
| **Offline kit in offline mode** | App used without internet | All mock data remains accessible; offline kit download simulates packaging (no real file I/O). |

### Loading States

- **AI Itinerary Generation**: Button text changes to "Synthesizing Itinerary..." + `CircularProgressIndicator` during `Future.delayed(900ms)`
- **Route Recovery Recalculation**: Immediate UI update within `recalculate()`; no explicit loading indicator beyond alert box state change
- **Scam Assessment**: Immediate; results appear below audit button
- **Offline Kit Download**: Button text changes to "Saving to Local Storage..." + `CircularProgressIndicator` during `Future.delayed(800ms)`
- **Translation**: No explicit loading; translation appears instantly on button tap

### Empty States

- **No destinations matching filter**: Grid/ListView shows nothing; the UI column remains but has zero children
- **No bookings**: "0 Active Vouchers Issued" text displayed at top of booking dashboard; voucher list empty
- **No phrases**: Phrasebook section still header-present but list has 0 items
- **No routes in route recovery**: Route list empty; feasibility secures message shown
- **No emergency contacts (beyond 2)**: Offline kit only shows first 2 contacts; scroll list has limited items

---