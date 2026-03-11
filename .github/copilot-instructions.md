# GitHub Copilot Instructions — HRIS MSI

> **Purpose of this file**: Provide Copilot agents with full context about
> the project so that any contributor (human or AI) can work on it
> correctly — even if the project is reopened 10 years from now.

---

## 1. Project Overview

**HRIS MSI** (Human Resource Information System — MSI) is a mobile-first
application built with Flutter. It manages employee data, attendance,
leave, payroll, and HR reporting for the organisation.

### Business Modules (current & planned)
| Module        | Status   | Description |
|---------------|----------|-------------|
| Auth          | ✅ Done  | Login, logout, session management |
| Dashboard     | ✅ Done  | Greeting, quick-info cards, shortcuts |
| Transaction   | 🔲 Shell | Leave, attendance, reimbursement, overtime, transfer |
| Master Data   | 🔲 Shell | Company, department, position, employee, payroll grades |
| System        | 🔲 Shell | Profile, settings, user management, audit log |
| Report        | 🔲 Shell | Employee, attendance, payroll, leave, performance reports |

---

## 2. Tech Stack & Versions

| Concern              | Package / Tool               |
|----------------------|------------------------------|
| Framework            | Flutter 3.x / Dart 3.x      |
| State management     | Riverpod (`flutter_riverpod`, `riverpod_annotation`, `riverpod_generator`) |
| Navigation           | GoRouter (`go_router`)       |
| HTTP client          | Dio (`dio`)                  |
| Functional utils     | fpdart (`fpdart`)            |
| Secure storage       | `flutter_secure_storage`     |
| Fonts                | `google_fonts` (Inter)       |
| Testing              | `flutter_test`, `mockito`, `mocktail` |

> **Important**: Never add a new dependency without discussing it first.
> Keep the dependency tree as small as possible.

---

## 3. Architecture — Clean Architecture + Riverpod

```
lib/
├── main.dart                  ← App entry point (ProviderScope → App)
├── app.dart                   ← MaterialApp.router with theme & GoRouter
│
├── core/                      ← Shared, framework-level code
│   ├── constants/
│   │   └── app_constants.dart ← All magic strings/numbers
│   ├── errors/
│   │   ├── exceptions.dart    ← Low-level exceptions (data layer)
│   │   └── failures.dart      ← Domain-level failures (sealed class)
│   ├── extensions/
│   │   └── context_extensions.dart
│   ├── router/
│   │   └── app_router.dart    ← GoRouter config + RoutePaths
│   ├── theme/
│   │   ├── app_colors.dart    ← Color palette (primaryBlue, darkBlue, …)
│   │   ├── app_text_styles.dart ← Text styles (Inter font)
│   │   └── app_theme.dart     ← ThemeData builder
│   └── widgets/               ← Shared reusable widgets
│       └── app_loading_indicator.dart
│
├── features/                  ← One folder per business module
│   ├── auth/
│   │   ├── data/
│   │   │   ├── datasources/   ← AuthRemoteDataSource, AuthLocalDataSource
│   │   │   ├── models/        ← UserModel (fromJson / toJson / toEntity)
│   │   │   └── repositories/  ← AuthRepositoryImpl
│   │   ├── domain/
│   │   │   ├── entities/      ← User (pure Dart)
│   │   │   ├── repositories/  ← AuthRepository (abstract)
│   │   │   └── usecases/      ← LoginUseCase, LogoutUseCase
│   │   └── presentation/
│   │       ├── pages/         ← LoginPage
│   │       ├── providers/     ← authProvider (Notifier + sealed AuthState)
│   │       └── widgets/
│   ├── splash/
│   │   └── presentation/pages/splash_page.dart
│   ├── main/
│   │   └── presentation/pages/main_shell_page.dart  ← Bottom nav shell
│   ├── dashboard/
│   │   └── presentation/pages/dashboard_page.dart
│   ├── transaction/
│   │   └── presentation/pages/transaction_page.dart
│   ├── master/
│   │   └── presentation/pages/master_page.dart
│   ├── system/
│   │   └── presentation/pages/system_page.dart
│   └── report/
│       └── presentation/pages/report_page.dart
│
└── shared/                    ← Cross-feature shared code
    ├── providers/
    └── services/
```

### Layer Rules (NEVER violate these)
1. **Domain layer** has ZERO dependencies on Flutter, packages, or the data layer.
2. **Data layer** may depend on domain (entities, repository interfaces) and external packages.
3. **Presentation layer** may depend on domain and Riverpod — never import data-layer classes directly.
4. Features must NOT import from other features' `data/` or `domain/` folders directly.
   Share via `shared/` providers instead.

---

## 4. Navigation (GoRouter)

All route paths live in `RoutePaths` inside `core/router/app_router.dart`.

| Path           | Page             | Notes |
|----------------|------------------|-------|
| `/`            | SplashPage       | Checks auth, then redirects |
| `/login`       | LoginPage        | Unauthenticated only |
| `/dashboard`   | DashboardPage    | Tab 0 inside MainShellPage |
| `/transaction` | TransactionPage  | Tab 1 |
| `/master`      | MasterPage       | Tab 2 |
| `/system`      | SystemPage       | Tab 3 |
| `/report`      | ReportPage       | Tab 4 |

**Adding a new sub-route**: add a child `GoRoute` under the relevant
`StatefulShellBranch` in `app_router.dart`.

---

## 5. State Management Patterns

### Auth state — sealed class + Notifier
```dart
sealed class AuthState { const AuthState(); }
class AuthInitial     extends AuthState { … }
class AuthLoading     extends AuthState { … }
class AuthAuthenticated extends AuthState { final User user; … }
class AuthUnauthenticated extends AuthState { … }
class AuthError       extends AuthState { final String message; … }
```
Use **pattern matching** (`switch (authState)`) in widgets.

### When to use which provider
| Need                       | Use                      |
|----------------------------|--------------------------|
| Simple sync state          | `Notifier`               |
| Async fetch + mutations    | `AsyncNotifier`          |
| One-shot async value       | `FutureProvider`         |
| Reactive stream            | `StreamProvider`         |
| Derived / computed value   | `Provider`               |

### Rules
- `ref.watch` in `build()` for reactivity.
- `ref.read` inside callbacks (button press, etc.).
- `ref.listen` for side effects (snackbar, navigation).
- Prefer `autoDispose`; use `keepAlive: true` only when the state
  must survive across the whole app lifetime.

---

## 6. Theme & Design Tokens

### Color Palette
```dart
primaryBlue  = Color(0xFF6A8EBB)
darkBlue     = Color(0xFF285FA1)
lightBlue    = Color(0xFF9FB7D6)
accentBlue   = Color(0xFF3F6FA8)
```
All colors → `core/theme/app_colors.dart`  
All text styles → `core/theme/app_text_styles.dart` (Google Fonts — Inter)  
Full ThemeData → `core/theme/app_theme.dart`

### UI conventions
- Default padding: **16 dp**.
- Default border radius: **12 dp** (buttons), **16 dp** (cards).
- Card style: white background, 1 px `AppColors.divider` border, no elevation.
- Gradient header: `AppColors.primaryGradient` with `borderRadius` 20–40.

---

## 7. Error Handling

- Domain layer uses **`sealed class Failure`** (`core/errors/failures.dart`).
- Data layer throws **typed exceptions** (`core/errors/exceptions.dart`).
- Repository implementations **catch** exceptions and return `Either<Failure, T>` (fpdart).
- Presentation layer folds `Either` or uses `AsyncValue.when`.

---

## 8. Coding Standards

### Dart Style
- **Null safety**: strict; never use `dynamic` unless absolutely necessary.
- **Max line length**: 80 characters.
- **Import order**: `dart:` → `package:flutter/` → third-party → project.
- **Const everywhere**: use `const` constructors and `const` values wherever possible.
- **final > var**: default to `final`; use `var` only if reassignment is required.
- Use `late final` when initialisation happens after declaration.

### Naming
| Element          | Convention          | Example |
|------------------|---------------------|---------|
| Files & folders  | `snake_case`        | `auth_repository.dart` |
| Classes          | `PascalCase`        | `LoginUseCase` |
| Variables        | `camelCase`         | `userName` |
| Constants        | `SCREAMING_SNAKE`   | `BASE_URL` |
| Private members  | `_camelCase`        | `_authState` |

### File Suffixes
`_page.dart`, `_widget.dart`, `_provider.dart`, `_notifier.dart`,
`_repository.dart`, `_model.dart`, `_entity.dart`, `_usecase.dart`,
`_service.dart`, `_test.dart`.

---

## 9. Adding a New Feature — Step by Step

1. Create folder: `lib/features/<feature_name>/`
2. **Domain**: entity → repository (abstract) → use-case(s).
3. **Data**: model (fromJson/toJson/toEntity) → data-source(s) → repository impl.
4. **Presentation**: provider → page → widgets.
5. **Route**: add `GoRoute` in `app_router.dart`.
6. **Tests**: unit tests for use-cases & repository impl; widget tests for pages.

---

## 10. Testing

```
test/
├── unit/
│   └── features/<feature>/
│       ├── data/
│       ├── domain/
│       └── presentation/
├── widget/
└── integration/
```
- Naming: `<class_name>_test.dart`.
- Pattern: `should <expected> when <condition>`.

---

## 11. Git Conventions

**Branches**: `main`, `develop`, `feature/<name>`, `bugfix/<name>`, `hotfix/<name>`, `release/<version>`.

**Commits**: `type(scope): description`  
Types: `feat`, `fix`, `docs`, `style`, `refactor`, `test`, `chore`.

---

## 12. Security Checklist

- No hardcoded API keys — use env vars or secure storage.
- Credentials stored via `flutter_secure_storage`.
- All auth data cleared on logout.
- Validate every user input at the form level.
- Sanitize data before rendering to prevent XSS.

---

## 13. Performance Quick-Reference

- `const` constructors on every immutable widget.
- `ListView.builder` for lists longer than ~20 items.
- `ref.watch(provider.select(...))` to avoid unnecessary rebuilds.
- `RepaintBoundary` around expensive render subtrees.
- Images: use `cached_network_image`; compress before upload.