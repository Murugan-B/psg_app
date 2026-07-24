# Database Inventory

*Pending Extraction from React Native Source (Phase 00/02.5)*

## Tables
- `profiles`
- `categories`
- `products`
- `staff`
- `attendance_logs`
- `orders`
- `order_items`
- `pending_login_requests`

## Triggers & Functions
- `handle_new_user()`
- `update_product_status()`
- `decrement_stock()` (Assumed from SQL)

## RLS Policies
- `profiles_select_all`, `profiles_update_own`, `profiles_admin_update_all`, `profiles_admin_insert`, `profiles_admin_delete`
- `allow_insert_pending`, `staff_read_own_pending`, `admin_update_pending`, `admin_delete_pending`
- (Will map products, categories, orders policies precisely in Phase 02.5)
