# Changelog

All notable changes to this project will be documented here.

## [Unreleased]

### Added
- GPS-default recovery journey with a supporting map and branching route tree.
- Explicit demo playback, journey clock, delay scenarios, and manual arrival.
- Foreground location permissions, checkpoint detection, and tracking error states.
- Recovery schedule, arrival detection, and responsive screen tests.

### Changed
- Split recovery into Current plan and Backup plans, with an always-visible map preview and labeled Map control.
- Confirmed backups become current and drive the demo's subsequent connection schedule.
- Polished vertical recovery branches with clearer time blocks, arrival/fare comparisons, and transfer margins.
- Added demo progress feedback, backup collapse, and higher-contrast action colors.
- Restored the detailed vertical recovery timeline selected from the reference image.
- Moved the live map to a top-right control and increased demo speed to 15 minutes per tick.
- Recovery now centers a fork-and-merge route tree with selectable parallel branches.
- Moved map and demo scenarios into progressive disclosure; simplified route details.
- Bundled Roboto font weights and shortened the recovery header.
- Recovery recommendations use coherent hardcoded schedules and transfer buffers.
- Confirmed mock recovery vouchers reflect the replacement transport mode.

### Fixed
- Visited checkpoints and completed legs now disappear from the active recovery timeline.
- Adding a delay to a paused demo now updates position and checkpoint state immediately.
- Recovery no longer recommends departed origin routes after reaching a checkpoint.
- No feasible route is returned when all replacement connections have been missed.
- Disabled Kotlin incremental caching to avoid Windows plugin build-cache failures.

### Removed
- 

## [1.0.0] - 2026-11-13

### Added
- Initial project features.
- AeroNova AI Virtual Travel Agent with 9 screens.
- Mock data service with destinations, hotels, transports, bookings, emergency contacts, phrases, and scam assessment.
- Route recovery engine with 3 route options and checkpoint delay simulation.
- Material Design 3 theming with primary #147FE8, secondary #FFF97316.
- Bottom navigation bar + drawer + navigation rail layout.
- Dashboard screen with welcome banner, quick action cards, active trip status, budget overview, and destination grid.
- AI trip planner with conversational prompt, form parameters, and generated itinerary display.
- Booking dashboard with hotel, train/flight, and local cab lists.
- Destination discovery grid with category filters and "Add to Planner" CTA.
- Offline kit screen with download button and cached vouchers/emergency contacts.
- Emergency assistance screen with SOS alert and speed dials.
- Translation screen with language selector and situational phrasebook.
- Scam verification screen with heuristic risk assessment.
- Smart route recovery screen with checkpoint simulator, scenario chips, and route possibilities.
- Data models: Activity, DayPlan, Itinerary, Destination, Hotel, TransportOption, BookingItem, JourneyLeg, RoutePossibility, CheckpointStatus, EmergencyContact, TravelPhrase, ScamRiskIndicator, ScamCheckAssessment.
- Material icons and custom color typography system.
- Roboto font family, ColorScheme based on seed colors.
