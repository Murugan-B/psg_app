# Animation Inventory

*Extracted directly from React Native Source via AST analysis. Zero AI assumptions.*

## Animated Splash (`AppNavigator.jsx`)
- **Properties Animated**: `fadeAnim`, `scaleAnim`, `translateAnim`, `dotsAnim`, `exitAnim`, `ring1Anim`, `ring2Anim`, `spinAnim`.
- **Rings Pulse Loop**: Uses `Animated.loop` and `Animated.sequence` with duration `1500` to scale between `1.03` and `0.97`.
- **Logo Spin**: Duration `2000` (rotates 0deg to 360deg).
- **Logo Float**: `Animated.spring(scaleAnim, { tension: 60, friction: 8 })`.
- **Bouncing Dots**: Delay increments by 150ms. Scales Y from 1 to 1.6 and opacity 0.3 to 1. Duration `300` up, `300` down.

## Navigation Transitions
- Defined in `RootNavigator`: `animation: 'fade'`, `animationDuration: 150`.
