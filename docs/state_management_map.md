# State Management Map

*Extracted directly from React Native Source. Zero AI assumptions.*

## AuthContext (`AuthContext.jsx`)
- Uses React `createContext`
- Variables: `session`, `profile`, `loading`
- Caching: Stores `cached_profile` and `cached_session` in `AsyncStorage`.
- Logic: Validates JWT metadata first, falls back to Database fetch `from('profiles')`.
- Actions: `signOut()`.

## Target Flutter Implementation (Phase 0)
- `Riverpod` will replace `AuthContext`.
- `AsyncNotifierProvider` or `StateNotifierProvider` will hold the AuthState (session, profile, loading).
- `SharedPreferences` will replace `AsyncStorage`.
