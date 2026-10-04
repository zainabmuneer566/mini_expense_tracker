# Mini Expense Tracker

A modern expense tracker built with Flutter and Material 3. Add, edit, delete, search and filter expenses, see monthly and category summaries, and keep your data after restarting the app.

## Features

- Add Expense (title, amount, category, date)
- Edit Expense (pre-filled form that really updates the data)
- Delete Expense (confirmation dialog + SnackBar)
- Expense List with card design
- 8 Categories with icons and colours
- Date Selection with readable dates (e.g. 04 Oct 2026)
- Total Expense Calculation (always computed, never hardcoded)
- Search by title or category
- Filtering by category and by month
- Monthly Total on the dashboard
- Category-wise Expenses with progress bars
- Form Validation
- Empty States (no expenses / no search results)
- Local Persistence with SharedPreferences

## Technologies

- Flutter
- Dart
- Material 3
- shared_preferences (only extra package)

## Flutter/Dart Version

Fill in the output of `flutter --version` from your machine here (the code needs Flutter 3.27+ / Dart 3.3+ because it uses `Color.withValues`).

## Architecture

```
lib/
├── main.dart                      # app entry, bottom navigation, FAB
├── models/expense.dart            # Expense model + ExpenseCategory enum
├── screens/
│   ├── dashboard_screen.dart      # overview, totals, category summary, recent
│   ├── expense_list_screen.dart   # search, filters, full list
│   ├── add_expense_screen.dart    # form used for Add and Edit
│   └── edit_expense_screen.dart   # thin wrapper: pre-filled form
├── widgets/                       # expense_card, summary_card, category_card, empty_state
├── services/
│   ├── local_storage_service.dart # JSON save/load (SharedPreferences)
│   └── expense_controller.dart    # ChangeNotifier: data + all calculations
└── utils/                         # app_colors, app_theme, helpers (formatting, dialogs)
```

`ExpenseController` is the single source of truth. Screens wrap their UI in `ListenableBuilder`, so every add/edit/delete refreshes the dashboard and list instantly. No state-management package is needed.

## How to Run

```bash
flutter pub get
flutter run
```

## What I Learned

- Building forms with `Form`, `TextFormField` and custom `FormField` validation
- `ChangeNotifier` + `ListenableBuilder` for simple state management
- Navigation with `Navigator.push` and a `NavigationBar`
- Persisting data as JSON with SharedPreferences
- Reusable widgets, theming with Material 3, and subtle animations

## Problems Faced

- Showing a SnackBar after deleting a card whose context was already gone: solved by grabbing `ScaffoldMessenger` before the async call.
- Overflow on small screens: solved with `Expanded`, `Wrap`, `FittedBox` and scrollable `ListView`s.
- Add and Edit forms duplicating code: solved by sharing one form screen.

## Future Improvements

- Supabase backend
- Authentication
- Cloud synchronization
- Charts/analytics
- Budget limits
- Notifications
- Export to PDF/CSV

## Screenshots

| Dashboard | Expense List | Add Expense |
|-----------|--------------|-------------|
| _add screenshot_ | _add screenshot_ | _add screenshot_ |

## Demo

APK / video link: _add link here_
