# Component Inventory

*Extracted from React Native Source File Structure.*

## Screens & Main Containers (Not Reusable)
- `Admin/Billing/Billing_page.jsx`
- `Admin/DayDetail/DayDetailScreen.jsx`
- `Admin/Home/HomePage.jsx`
- `Admin/Inventory/Brands/Brands.jsx`
- `Admin/Inventory/Cart/Cart.jsx`
- `Admin/Inventory/Category/Add_Category.jsx`
- `Admin/Inventory/Category/Category.jsx`
- `Admin/Inventory/Products/Add_Product.jsx`
- `Admin/Inventory/Products/AdminProducts.jsx`
- `Admin/Inventory/Products/Products.jsx`
- `Admin/Inventory/Products/Productsdetails.jsx`
- `Admin/Inventory/StockHistory/StockHistory.jsx`
- `Admin/More/More.jsx`
- `Admin/ProductsSold/ProductsSold.jsx`
- `Admin/Settings/Settings.jsx`
- `Admin/StaffAttendance/StaffAttendance.jsx`
- `Admin/StaffList/StaffList.jsx`
- `Login/Login.jsx`
- `Login/Register.jsx`
- `Pos/Pos.jsx`
- `Staff/Staffdashboard/StaffDashboard.jsx`
- `Staff/StaffScanAttendance/StaffScanAttendance.jsx`

## Reusable Components Discovered
*Note: The React Native project does NOT use a centralized `shared` or `components` folder for buttons/cards. UI is built largely inline. To comply with Phase 03.5, we must abstract these during migration based on the inline styles.*
- `NavBar.jsx` (Global component)
- `AppNavigator.jsx` (Routing container)

## Target Reusable Components for Flutter (Phase 03.5)
Since the React Native UI duplicates these structurally, we will enforce Clean Architecture in Flutter by building:
- `PrimaryButton`, `SecondaryButton`, `OutlinedButton`, `DangerButton`
- `ProductCard`, `DashboardCard`, `InventoryCard`
- `SearchInput`, `DropdownInput`, `QuantityInput`
- `ConfirmationDialog`, `LoadingDialog`
- `ShimmerLoader`, `EmptyStateContainer`
