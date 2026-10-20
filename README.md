# Products Explorer

A production-quality Flutter application built with Clean Architecture, Cubit (`flutter_bloc`), Dio, GetIt, and GoRouter. It fetches products from DummyJSON, presents them in an adaptive responsive grid, provides server-side debounced search, supports infinite scrolling pagination, and showcases complete product details with image galleries and error resilience.

---

## Table of Contents
1. [Project Overview](#1-project-overview)
2. [Tech Stack](#2-tech-stack)
3. [Architecture](#3-architecture)
4. [Features](#4-features)
5. [Testing](#5-testing)
6. [Folder Structure](#6-folder-structure)
7. [How to Run the Project](#7-how-to-run-the-project)
8. [Future Improvements](#8-future-improvements)
9. [Screenshots Section](#9-screenshots-section)
10. [Social Links](#10-social-links)

---

## 1. Project Overview

**Products Explorer** demonstrates clean, scalable Flutter software engineering for enterprise-grade applications. It adheres strictly to:
* **Clean Architecture** with a **Feature-First** structure.
* **SOLID Principles** & Separation of Concerns across Presentation, Domain, and Data layers.
* **Predictable State Management** using `Cubit` with immutable states.
* **Defensive Error Handling** transforming HTTP and parsing exceptions into user-friendly domain `Failure` objects without leaking technical exceptions to the UI.
* **Responsive UI** using `flutter_screenutil` and adaptive grid layouts.

---

## 2. Tech Stack

| Category | Technology / Package | Purpose & Rationale |
| :--- | :--- | :--- |
| **Framework** | Flutter (Dart `^3.10.0`) | Cross-platform UI toolkit for building natively compiled applications. |
| **State Management** | `flutter_bloc` (`^9.1.1`) | Enterprise-grade state management via `Cubit`, ensuring deterministic unidirectional data flow. |
| **Network Client** | `dio` (`^5.11.1`) | Powerful HTTP client providing timeouts, interceptors, and cancel tokens. |
| **Dependency Injection** | `get_it` (`^9.3.0`) | Lightweight service locator for clean architecture dependency setup. |
| **Routing** | `go_router` (`^17.5.0`) | Declarative routing supporting path parameters (`/products/:id`) and deep linking. |
| **Search Optimization** | `flutter_debouncer` (`^2.1.1`) | Lightweight debouncer to postpone search execution until user typing pauses. |
| **Image Caching** | `cached_network_image` (`^3.4.1`) | High-performance image caching with placeholder spinners and error fallbacks. |
| **Responsive Design** | `flutter_screenutil` (`^5.9.3`) | Screen adaptation adapter for scalable typography and padding sizing. |
| **Utilities** | `equatable` (`^3.0.0`) | Value-based equality comparison for immutable states and entities. |

---

## 3. Architecture

The project is structured according to **Clean Architecture** principles, separated into three decoupled layers to enforce a strict dependency rule (outer layers depend on inner layers, but inner layers know nothing about outer details):

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│   Pages, Reusable Widgets, Cubits & Immutable States   │
└───────────────────────────┬────────────────────────────┘
                            │ depends on Domain
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│   Entities, Repository Interfaces & Domain Use Cases   │
│         (Zero dependencies on Flutter or Dio)          │
└───────────────────────────▲────────────────────────────┘
                            │ implemented by Data
┌───────────────────────────┴────────────────────────────┐
│                        Data Layer                      │
│    Data Models, Remote Data Sources & Repositories     │
│        (Safe JSON parsing & Failure mapping)           │
└───────────────────────────▲────────────────────────────┘
```

### Presentation Pattern: View -> Section -> Widget
* **Views (`Pages`)**: Compose modular screen sections and handle route-level lifecycle.
* **Sections**: Connect UI state from Cubits and dispatch user events.
* **Widgets**: Pure, reusable presentation components that receive data via constructor parameters and contain zero business logic or API calls.

### Unified Functional Response Pattern: `ApiResult<T>`
Repositories return an `ApiResult<T>` sealed class:
```dart
result.fold(
  (failure) => handleFailure(failure),
  (data) => handleSuccess(data),
);
```

---

## 4. Features

* **Responsive Product Grid**: Adaptive layout rendering 2 columns on mobile devices, 3 columns on tablets, and 4 columns on large screens.
* **Server-Side Debounced Search**: 350ms input debouncing via `flutter_debouncer`, query trimming, quick clear buttons, and immediate search submission.
* **Infinite Scrolling Pagination**: Automatic loading of subsequent 20-product pages upon reaching the bottom threshold with scroll listeners.
* **Pull-to-Refresh**: Seamless catalog refreshing preserving scroll and active query state.
* **Stale Request Cancellation**: Requests are cancelled via Dio `CancelToken` and protected by incremental request IDs, preventing out-of-order responses from overwriting newer queries.
* **Preserved State on Failure**: Failed pagination attempts preserve already loaded products and provide inline retry controls.
* **Product Details Screen**: Complete specifications including dynamic image thumbnail gallery, pricing, discount calculations, ratings, stock counts, shipping, warranty, and return policies.
* **Comprehensive UI States**:
  * Polished Shimmer / Skeleton layout during initial loading.
  * Full-screen error views with interactive retry buttons.
  * Distinct empty states for empty catalogs vs. zero search results.
  * Inline bottom loaders and error banners for pagination.
* **Network Image Caching**: Image caching with placeholder spinners and fallbacks.

---

## 5. Testing

All unit and widget tests are deterministic and use `mocktail` along with `bloc_test` to mock repositories and use cases.

### Run all automated tests:
```bash
flutter test
```

### Test Suite Coverage:
* **`ProductModel JSON Parsing`**: Validates JSON mapping, optional field safety, discount formulas, and pagination metadata extraction.
* **`ProductRepositoryImpl`**: Verifies correct error mapping from network exceptions (`ServerException`, `NetworkException`, `TimeoutException`, etc.) into user-safe domain `Failure` objects.
* **`ProductsCubit`**: Tests initial loading success/failure flows, debounced search updates, empty responses, pagination appending logic, and stale request discarding.
* **`ProductDetailsCubit`**: Ensures details fetching and recovery retry mechanics operate smoothly.
* **`ProductsExplorerApp` Smoke Test**: Validates top-level widget mounting and initial route layout rendering.

---

## 6. Folder Structure

```text
lib/
├── core/
│   ├── di/
│   │   └── injection_container.dart       # GetIt dependency injection setup
│   ├── error/
│   │   ├── exceptions.dart                # Technical exceptions (Server, Network, etc.)
│   │   └── failures.dart                  # User-safe domain failures
│   ├── network/
│   │   ├── api_consumer.dart              # Abstract HTTP consumer interface
│   │   ├── api_endpoints.dart             # Centralized API endpoint constants
│   │   ├── api_result.dart                # Sealed functional result wrapper
│   │   └── dio_client.dart                # Shared Dio instance with timeouts & logging
│   ├── router/
│   │   └── app_router.dart                # Central GoRouter configuration
│   ├── theme/
│   │   ├── app_colors.dart                # Centralized color tokens
│   │   ├── app_text_style.dart            # Centralized responsive typography
│   │   └── app_theme.dart                 # Material 3 theme configuration
│   └── widgets/
│       ├── app_empty_view.dart            # Reusable empty state view
│       ├── app_error_view.dart            # Reusable error view with retry
│       └── app_loading_view.dart          # Reusable loading indicator
├── features/
│   └── products/
│       ├── data/
│       │   ├── datasources/
│       │   │   └── product_remote_data_source.dart
│       │   ├── models/
│       │   │   ├── product_model.dart
│       │   │   └── products_response_model.dart
│       │   └── repositories/
│       │       └── product_repository_impl.dart
│       ├── domain/
│       │   ├── entities/
│       │   │   ├── product_entity.dart
│       │   │   └── products_response_entity.dart
│       │   ├── repositories/
│       │   │   └── product_repository.dart
│       │   └── usecases/
│       │       ├── get_product_details.dart
│       │       ├── get_products.dart
│       │       └── search_products.dart
│       └── presentation/
│           ├── cubits/
│           │   ├── product_details_cubit.dart
│           │   ├── product_details_state.dart
│           │   ├── products_cubit.dart
│           │   └── products_state.dart
│           ├── pages/
│           │   ├── product_details_page.dart
│           │   └── products_page.dart
│           └── widgets/
│               ├── product_card.dart
│               ├── product_grid.dart
│               ├── product_search_field.dart
│               ├── products_pagination_loader.dart
│               └── products_skeleton_grid.dart
└── main.dart                              # Application initialization and entry point
```

---

## 7. How to Run the Project

### Prerequisites
* Ensure you have the **Flutter SDK** (`^3.10.0` or higher) installed on your machine.

### Step 1: Clone the repository & navigate to project root
```bash
cd flutter_task
```

### Step 2: Install dependencies
```bash
flutter pub get
```

### Step 3: Run the application
Choose your target platform and execute:
```bash
# Run on a connected physical device or emulator
flutter run

# Run on Chrome (Web)
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```

---

## 8. Future Improvements

* [ ] **Local Caching**: Implement Hive or Drift for offline product browsing and local cart persistence.
* [ ] **Category Filtering**: Add category chips to filter products dynamically by tags or types.
* [ ] **Dark Mode Support**: Extend the theme configuration layer to fully support system-synced dark themes.
* [ ] **Localization (i18n)**: Integrate `easy_localization` to support multi-language capabilities.

---

## 9. Screenshots Section

*(Add screenshots or a GIF demo of your app running on mobile/desktop here)*

| Products Explorer Grid | Product Details View | Search & Loading State |
| :---: | :---: | :---: |
| <img width="720" height="1600" alt="WhatsApp Image 2026-10-20 at 11 43 00 PM(1)" src="https://github.com/user-attachments/assets/c63d0b2c-994b-48e2-b65a-01207c3970cb" /> | <img width="720" height="1600" alt="WhatsApp Image 2026-10-20 at 11 43 00 PM(3)" src="https://github.com/user-attachments/assets/a9a606bc-3474-4e25-8f31-803584955664" /> 
| <img width="720" height="1600" alt="WhatsApp Image 2026-10-20 at 11 43 00 PM" src="https://github.com/user-attachments/assets/69f8a42b-e75a-4673-b958-2b77242e1335" /> |
---

## 10. Social Links

If you have any questions, feedback, or would like to collaborate, feel free to reach out:

* **GitHub**: [@ManarGhareeb](https://github.com/ManarGhareeb)
* **LinkedIn**: [Manar Ghareeb](https://linkedin.com/in/manar-ghareeb)
* **Email**: manar.ghareeb@example.com
