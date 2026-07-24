# Dependency Graph

## Screens -> Components
- `LoginScreen` uses `useAuth()` hook.
- `StaffDashboard` uses `NavBar`.
- `AdminProducts` uses inline `ProductCard` equivalents.

## Contexts -> Services
- `AuthContext` relies on `supabase.js` config and `AsyncStorage`.

## DB -> UI
- UI strictly depends on `products` table schema, fetching `sku`, `price`, `stockQty`.
