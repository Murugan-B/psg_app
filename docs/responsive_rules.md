# Responsive Rules

*Extracted directly from React Native Source. Zero AI assumptions.*

## Safe Area
- Uses `SafeAreaView` from `react-native` globally across screen roots (e.g. `AuthContext.jsx`).

## Window Dimensions
- Uses `Dimensions.get('window').width` explicitly.
- Found in `AppNavigator.jsx`: `const { width } = Dimensions.get('window');`
- Found: `width: width * 0.65` for Progress Bar.

## Platform Specifics
- Uses `Platform.OS` for specific styling rules (will be mapped directly to `Platform.isAndroid` / `Platform.isIOS` in Flutter).
