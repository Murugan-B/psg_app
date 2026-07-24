# Repository Mapping

| React Native Service/Logic | Flutter Repository | Flutter DataSource | Flutter Provider |
|----------------------------|--------------------|--------------------|------------------|
| `AuthContext.jsx` | `AuthRepository` | `SupabaseAuthDataSource` | `authProvider` |
| Inline Supabase (Products) | `InventoryRepository`| `SupabaseInventoryDataSource` | `inventoryProvider` |
| Inline Cart State | `CartRepository` | `LocalCartDataSource` | `cartProvider` |
| `AppNavigator` Routing | `NavigationService` | `GoRouter` | `routerProvider` |
