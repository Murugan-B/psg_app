# VishnuMobile Enterprise Flutter Migration Plan (v1.1)

## Mission
Zero-Difference Enterprise Migration (React Native → Flutter).
Only the technology stack changes. Everything else remains identical.

## Enterprise Constitution & NO AI ASSUMPTIONS
- **NO AI ASSUMPTIONS:** The AI must never guess colors, spacing, business logic, SQL, API, animations, sizes, icons, or layouts. Always inspect the React Native source of truth.
- **0 Pixels Difference:** The Flutter UI will be indistinguishable from the React Native UI.
- **Database Freeze:** No modifications to the schema, tables, triggers, or RLS.

## Migration Phases

- **Phase 00:** Full React Native Audit & Implementation Inventory
- **Phase 01:** Flutter Project Creation
- **Phase 02:** Enterprise Folder Structure
- **Phase 02.5:** Design System Extraction (Extract all tokens into theme_tokens.md)
- **Phase 02.6:** Asset Extraction (Extract all assets into asset_inventory.md)
- **Phase 03:** Theme Migration (Implementing theme_tokens.md into ThemeData)
- **Phase 03.5:** Reusable Component Library (Building buttons, cards, dialogs, inputs)
- **Phase 04:** Shared Widgets
- **Phase 05:** Splash + Authentication (Mock UI & Logic)
- **Phase 05.5:** Navigation Mapping (Generate navigation_map.md)
- **Phase 06:** Navigation (GoRouter implementation)
- **Phase 07-13:** Feature Modules (Admin, POS, Inventory, Billing, Attendance, Reports, Settings) built with Mock Repositories.
- **Phase 14:** Complete UI Validation.
- **Phase 15:** Supabase Integration (Auth → Dashboard → Inventory → POS → Billing → Attendance → Reports → Settings → Cloudinary).
- **Phase 16:** Performance Optimization.
- **Phase 17:** Production Testing.
- **Phase 18:** Final Validation (100% Match).
