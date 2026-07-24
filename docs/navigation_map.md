# Navigation Map

*Extracted directly from React Native `AppNavigator.jsx`. Zero AI assumptions.*

## Navigation Stack (React Navigation Native Stack)
- `Login` (Initial route for unauthenticated)
- `PendingApproval` (For users waiting for admin confirmation)

## Admin Stack (`role === 'admin'`)
- `MainTabs` (AdminTabs - Bottom Nav)
- `AddCategory`
- `Products`
- `Cart`
- `Billing`
- `AddProduct`
- `ProductDetails`
- `StaffList`
- `Settings`
- `StaffAttendance`
- `Brands`
- `AdminProducts`
- `DayDetail`
- `ProductsSoldScreen` / `ProductsSoldReport`
- `StockHistory`

## Staff Stack (`role === 'staff'`)
- `StaffTabs` (Bottom Nav)
- `Products`
- `Cart`
- `Billing`
- `ProductDetails`
- `StaffAttendance` (If 'inactive' role)

## Transitions
- Animation globally defined as: `animation: 'fade'`, `animationDuration: 150`
- Content style background: `#F5F6FA`
