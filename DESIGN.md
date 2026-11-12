# DESIGN.md — UI/UX Design Documentation

## A. Design Philosophy

**Application Design Concept:**
AeroNova AI is a Virtual Travel Agent application presenting an "AI Command Center" experience for travel planning, route recovery, and emergency assistance. The design targets users who need intelligent, conversational travel assistance with practical tools for trip management, booking, and offline access.

**Target Audience:**
- Frequent travelers and travel enthusiasts
- Users who value AI-assisted trip planning
- Individuals needing route recovery and emergency assistance
- Travelers who need offline access to vouchers and contacts

**Design Goals:**
- Provide a command-center layout with quick access to all travel functions
- Enable natural language trip planning via conversational AI
- Offer visual route monitoring with checkpoint tracking
- Ensure zero-connectivity access through offline kits
- Present emergency assistance clearly and rapidly

**Overall Visual Direction:**
- Dark dashboard header with indigo/blue accent (AeroNova branding)
- Clean white cards with subtle borders and cool-gray typography
- Orange accent (0xFFF97316) for primary actions and warnings
- Purple accent (0xFF8B5CF6) for offline/secondary actions
- Green/teal for success states
- Consistent Material Design 3 patterns with custom color treatment

---

## B. Color System

| Role | Color | Value |
|------|-------|-------|
| Primary | AeroNova Blue | `#147FE8` |
| Secondary | AeroNova Orange | `#FFF97316` |
| On-primary | White | `#FFFFFF` |
| On-secondary | Orange-dark | `#F57F17` (derived) |
| Surface | White | `#FFFFFF` |
| Background | Frosted Sky | `#F8FAFC` |
| Error/Danger | Red | `#EF4444` (used via red.shade*) |
| Success | Green | `#10B981` |
| Warning | Amber | `#F59E0B` |
| Info | Blue | `#3B82F6` (used in stepper) |
| On-background | Dark Slate | `#0F172A` |
| On-surface | | `#1E293B` |
| On-muted | | `#64748B` |
| On-dim | | `#94A3B8` |

**Gradient Usage:**
- Dashboard welcome banner: LinearGradient `[0xFF0F172A, 0xFF1E293B, 0xFF0F172A]`
- Booking dashboard header: LinearGradient `[0xFF0F172A, 0xFF064E3B]`
- Emergency SOS banner: LinearGradient `[0xFF881337, 0xFF4C0519, 0xFF0F172A]`
- Offline kit banner: LinearGradient `[0xFF0F172A, 0xFF312E81]`
- Route recovery banner: LinearGradient `[0xFF0F172A, 0xFF1E293B, 0xFF1E1B4B]`

---

## C. Typography

| Element | Family | Size | Weight | Color |
|---------|--------|------|--------|-------|
| Display/Header (large) | Roboto | 24-40 | 800 (ExtraBold) | `#0F172A` |
| Title/Section | Roboto | 15-20 | 700 (Bold) | `#0F172A` |
| Subtitle/Capture | Roboto | 11-13 | 600 (SemiBold) | `#64748B` |
| Body/Text | Roboto | 10-12 | 400 (Regular) | `#475569` |
| Caption/Meta | Roboto | 8-10 | 400 (Regular) | `#64748B` |
| Chip Label | Roboto | 9-11 | 500 (Medium) | `#334155` / `#0F172A` |
| Interest Chip | Roboto | 11 | 600 (SemiBold) | `#147FE8` / `#475569` |
| Progress Value | Roboto | 11-12 | 700 (Bold) | `#10B981` |

**Heading Styles:**
- H1: `24px, FontWeight.w800, letterSpacing: -0.5, color: #0F172A`
- H2: `18px, FontWeight.w700, color: #0F172A`
- H3: `15px, FontWeight.w600, color: #0F172A`

---

## D. Components

### Buttons
- **Elevated Button**: White background, colored foreground (primary: `#147FE8`, secondary: `#0F172A`, success: `#10B981`, warning: `#F59E0B`), 14-20px padding, rounded corners (10-14px), elevation disabled
- **Text Button**: Minimal styling, often icon-only or with subtle underline
- **Outline Button**: Transparent fill, colored border, appears in dialogs and action bars
- **Floating Action Pattern**: Not used; action represented via bottom nav or drawer

### Cards
- **Action Card**: White background, 20px border radius, 2px border `#E2E8F0`, contains icon + title + subtitle, tap target with `InkWell`
- **Trip Card (Booking)**: White background, 20px border radius, 2px border `#E2E8F0`, image stack + details + CTA button
- **Stepper Circle**: 24px diameter, circular, colored fill with check or initial, 4px padding below label
- **Status Card**: White background, 24px border radius, 1px border `#E2E8F0`, contains status text and progress indicator

### Input Fields
- **Outlined TextField**: Border radius 12-16, filled background `#F8FAFC`, border color `#E2E8FC`, hover/focus state with primary color
- **Dropdown Button FormField**: Border radius 12, isDense true, items with standard text style
- **Interest/Filter Chip**: Selected state with colored background (`#EFF6FF` for interest, `#FFFFFF` for category), border radius 12, checkmark icon

### Navigation Bars
- **BottomNavigationBar**: Fixed type, 5 items, selected color `#147FE8`, unselected `#64748B`
- **NavigationRail**: For wide screens (>=768px), 5 destinations, icon + label
- **Drawer**: Left-side slideout, header with logo/icon, divider tiles with icon + text

### Dialogs and Modals
- **AlertDialog**: Rounded corners 20px, padded content, two-action pattern (cancel/confirm)
- **ScaffoldMessenger Snackbar**: Brief messages, custom background colors per severity

### Icons
- Material Icons set: `flight_takeoff`, `alt_route`, `auto_awesome`, `explore`, `download_for_offline`, `confirmation_number`, `emergency`, `translate`, `security`
- Colored per accent scheme (primary orange, secondary blue, etc.)

### Other Reusable Components
- **Stepper Circle** (`_buildStepCircle`): Circular status indicator with label and time
- **Action Chip / Filter Chip**: Category selection, interest toggling
- **Category Button**: Pill-shaped category filter
- **Scenario Chip**: Quick scenario selection in route recovery

---

## E. Screen Documentation

### 1. DashboardScreen (`lib/screens/dashboard_screen.dart`)
- **Purpose**: Main command center showing active trip status, quick actions, budget overview, and trending destinations
- **Main UI Elements**:
  - Welcome banner with gradient, AeroNova AI branding, user name, active corridor info
  - Quick Actions Grid (3 cards: Smart Route Recovery, AI Trip Planner, Offline Trip Kit)
  - Active Trip Status Card with checkpoint stepper
  - Budget Overview progress bar
  - Featured Destinations horizontal scroll grid
- **User Interactions**: Tap action cards to navigate, stepper navigation, budget interaction
- **Navigation Destinations**: Tabs 1 → SmartRouteRecoveryScreen, Tab 2 → AiTripPlannerScreen, Tab 4 → OfflineKitScreen, Tab 3 → DestinationDiscoveryScreen
- **Responsive**: BottomNavigationBar for narrow screens (<768px), NavigationRail for wide screens

### 2. BookingDashboardScreen (`lib/screens/booking_dashboard_screen.dart`)
- **Purpose**: Manage travel bookings for hotels, trains/flights, and local cabs
- **Main UI Elements**:
  - Header with gradient, title, subtitle, voucher count
  - TabBar with 3 tabs: Hotels & Stays, Trains & Flights, Ola / Uber Cabs
  - List views per tab with image, details, and booking CTA buttons
- **User Interactions**: Tab selection, Book/Book Room button taps
- **Navigation Destinations**: Return to main dashboard via onNavigateTab
- **Responsive**: Single column layout (mobile), tabbed interface preserved

### 3. AiTripPlannerScreen (`lib/screens/ai_trip_planner_screen.dart`)
- **Purpose**: Conversational AI trip planner with parameter customization
- **Main UI Elements**:
  - Conversational prompt box with text field and "Generate AI Itinerary" button
  - Form parameters: starting location, destination, nights, budget tier, travel interests
  - Generated itinerary display with hero image, day tabs, and activity cards
- **User Interactions**: Type prompt → generate, adjust parameters, select day, save offline
- **Navigation Destinations**: Return via onSaveOffline to MainAppShell
- **Responsive**: Single-column layout; form parameters in rows

### 4. DestinationDiscoveryScreen (`lib/screens/destination_discovery_screen.dart`)
- **Purpose**: Browse and discover popular and hidden-gem destinations
- **Main UI Elements**:
  - Header with title, subtitle, category filters (All / Popular / Hidden Gems)
  - Grid of destination cards with image, category badge, name, description, highlights, and "Add to Planner" CTA
- **User Interactions**: Category filter taps, search via query (extension), add destination
- **Navigation Destinations**: Add to itinerary planner (navigates to tab 2)
- **Responsive**: Grid layout preserved; scroll direction horizontal for wide, vertical for mobile

### 5. OfflineKitScreen (`lib/screens/offline_kit_screen.dart`)
- **Purpose**: Offline-accessible trip kit with cached vouchers and emergency contacts
- **Main UI Elements**:
  - Banner with gradient, title "Offline Travel Kit", LOCAL STORAGE CACHE tag
  - Download button for packaging trip
  - Cached Digital Vouchers list (booking count)
  - Emergency Contacts directory (top 2 contacts)
- **User Interactions**: Download trip, view vouchers, contact phone numbers
- **Navigation Destinations**: Return via drawer or bottom nav
- **Responsive**: Single column; emergency contacts limited to 2 entries

### 6. EmergencyAssistanceScreen (`lib/screens/emergency_assistance_screen.dart`)
- **Purpose**: SOS activation and local emergency facility directory
- **Main UI Elements**:
  - SOS banner with gradient, activation button, countdown timer
  - Speed dial cards: 112 Police, 108 Ambulance, 1363 Tourist Helpline
  - Verified contacts list for Jodhpur facilities
- **User Interactions**: SOS trigger (starts 5s countdown), cancel SOS, call buttons
- **Navigation Destinations**: Return via drawer
- **Responsive**: Full-width cards; countdown only during SOS active

### 7. TranslationScreen (`lib/screens/translation_screen.dart`)
- **Purpose**: Situational phrasebook with quick translation and language selector
- **Main UI Elements**:
  - Header with title, subtitle, language buttons (Italian / Hindi)
  - Quick text translator with input + Translate button
  - Phrasebook list with English, translated, and phonetic columns
- **User Interactions**: Language switch, translate custom text, play pronunciation (Snackbar feedback)
- **Navigation Destinations**: Return via drawer
- **Responsive**: Single column; language buttons inline

### 8. ScamVerificationScreen (`lib/screens/scam_verification_screen.dart`)
- **Purpose**: Travel scam & listing verification with risk assessment
- **Main UI Elements**:
  - Header with title and description
  - Form: suspicious communication text + payment method dropdown
  - "Audit Listing" CTA button
  - Audit result: risk score dial, verdict badge, risk signals, disclaimer
- **User Interactions**: Paste text → audit, change payment method, view results
- **Navigation Destinations**: Return via drawer
- **Responsive**: Single column; results expand below form

### 9. SmartRouteRecoveryScreen (`lib/screens/smart_route_recovery_screen.dart`)
- **Purpose**: Interactive checkpoint delay simulator with autonomous route recovery engine
- **Main UI Elements**:
  - Top banner with gradient, engine branding, feasibility status
  - Live alert box with color-coded severity (danger/warning/info)
  - Interactive simulator: checkpoint dropdown + delay slider
  - Quick scenario chips (4 preset scenarios)
  - Checkpoint stepper progress cards
  - Journey possibilities list with route legs and CTA buttons
- **User Interactions**: Adjust checkpoint/slider, select scenarios, rebook route
- **Navigation Destinations**: Return via drawer or main dashboard
- **Responsive**: Single column; stepper height-limited (110px)

---

## F. UI/UX Guidelines

### Spacing System
- **Component padding**: 12px, 16px, 20px, 24px
- **Section spacing**: 16px (small), 20px (medium), 24px (large), 32xl (section divider)
- **Grid gutter**: 14px between items in horizontal lists
- **Bottom navigation bar gap**: 8px between action icons

### Border Radius
- **Small**: 8px (input borders, chip corners)
- **Medium**: 12px (dropdown, category buttons)
- **Large**: 16-20px (cards, action containers)
- **X-Large**: 24px (welcome banners, stepper circles, main cards)
- **Full round**: Circle (24px stepper, checkpoint status dots)

### Shadows
- **Subtle**: `Colors.black.withOpacity(0.12), blurRadius: 18, offset: Offset(0, 8)` (welcome banner)
- **Card**: `Colors.black.withOpacity(0.04), blurRadius: 12, offset: Offset(0, 4)` (default card)
- **Strong**: `Colors.black.withOpacity(0.15), blurRadius: 20, offset: Offset(0, 8)` (route recovery banner)

### Layout Consistency
- Maximum container width: implicitly constrained by `Scaffold` body padding (20px)
- Grid items: fixed widths (220px for destination cards, 180px for checkpoint stepper)
- Side margins: 20px consistent across screens

### Responsive Design
- **Breakpoint**: 768px (tablet/desktop)
- **Narrow (<768px)**: BottomNavigationBar (5 items), single-column layout, NavigationRail hidden
- **Wide (>=768px)**: NavigationRail (first 5 destinations), expanded body, bottom nav set to null
- **Font scaling**: `fontSize` values remain constant; `letterSpacing` adjusts density

### Loading States
- **CircularProgressIndicator**: Primary color `#147FE8`, size 16-20px
- **Skeleton Pattern**: Not explicitly used; progress indicated by button text change (`Synthesizing...`) and disabled state
- **Full-screen blockers**: Not used; in-app indicators only

### Empty States
- **No destinations**: Grid simply has 0 items (empty ListView)
- **No bookings**: "0 Active Vouchers Issued" text displayed
- **No phrases**: Phrasebook list collapses
- **No routes**: Route list empty

### Error States
- **ScaffoldMessenger Snackbar**: Used for user feedback on actions
- **Red-bordered cards**: Indicate problematic state (e.g., missed connections shown as red background)
- **Risk colors**: Red for high danger, amber for warning, green for safe/low risk

---

## G. Design Rules (for AI Agents & Future Developers)

1. **Never deviate from the primary color palette**: `#147FE8` (primary), `#FFF97316` (secondary), `#0F172A` (on-background), `#F8FAFC` (background). All new components must reference these values.

2. **Always use Material Design 3**: `useMaterial3: true` in Theme. New components must follow Material 3 specifications.

3. **Respect the breakpoint at 768px**: BottomNavigationBar for narrow, NavigationRail for wide. Do not mix layouts across the breakpoint.

4. **Component reuse**: Reuse `_buildActionCard`, `_buildStepCircle`, and category button patterns from `dashboard_screen.dart`. Do not create duplicated card structures.

5. **Border radius consistency**: Use the defined sizes (8/12/16/20/24px). Do not use arbitrary radii.

6. **Typography hierarchy**: Always use Roboto. Headings use `FontWeight.bold` or `w700`; body uses `w400`/`w500`. Never use system fonts.

7. **Color semantics**: 
   - `#147FE8` = primary action, primary brand
   - `#FFF97316` = warning, secondary action, scenario chips
   - `#10B981` = success, budget remaining, on-time status
   - Red shades = errors, missed connections, danger
   - Amber `#F59E0B` = warnings (scenario chips)
   - Purple `#8B5CF6` = offline/secondary actions

8. **Gradient direction**: Always `LinearGradient` with `begin: Alignment.topLeft, end: Alignment.bottomRight` unless otherwise specified in screen documentation.

9. **Spacing**: Use the defined values (12/16/20/24/32). Do not use arbitrary padding values.

10. **Accessibility**: Maintain contrast ratios; use defined text colors for foreground/background combinations. Do not place light text on light backgrounds.

---