# Products Explorer

A production-quality Flutter application built with Clean Architecture, Cubit (`flutter_bloc`), Dio, GetIt, and GoRouter. It fetches products from DummyJSON, presents them in an adaptive responsive grid, provides server-side debounced search, supports infinite scrolling pagination, and showcases complete product details with image galleries and error resilience.

---

## Table of Contents
1. [Project Overview](#project-overview)
2. [Features](#features)
3. [Architecture Explanation](#architecture-explanation)
4. [Folder Structure](#folder-structure)
5. [Packages Used & Rationale](#packages-used--rationale)
6. [API Endpoints](#api-endpoints)
7. [Search Debouncing & Pagination Strategy](#search-debouncing--pagination-strategy)
8. [Setup & Run Instructions](#setup--run-instructions)
9. [Testing Instructions](#testing-instructions)

---

## 1. Project Overview

**Products Explorer** demonstrates clean, scalable Flutter software engineering for enterprise-grade applications. It adheres strictly to:
- **Clean Architecture** with a **Feature-First** structure.
- **SOLID Principles** & Separation of Concerns across Presentation, Domain, and Data layers.
- **Predictable State Management** using `Cubit` with immutable states.
- **Defensive Error Handling** transforming HTTP and parsing exceptions into user-friendly domain `Failure` objects without leaking technical exceptions to the UI.
- **Responsive UI** using `flutter_screenutil` and adaptive grid layouts.

---

## 2. Features

- **Responsive Product Grid**: Adaptive layout rendering 2 columns on mobile devices, 3 columns on tablets, and 4 columns on large screens.
- **Server-Side Debounced Search**: 350ms input debouncing, trimming, quick clear button, and immediate search submission.
- **Infinite Scrolling Pagination**: Automatic loading of subsequent 20-product pages upon reaching the bottom threshold with scroll listeners.
- **Pull-to-Refresh**: Seamless catalog refreshing preserving scroll and active query state.
- **Stale Request Cancellation**: Requests are cancelled via `CancelToken` and protected by incremental request IDs, preventing out-of-order responses from overwriting newer queries.
- **Preserved State on Failure**: Failed pagination attempts preserve already loaded products and provide inline retry controls.
- **Product Details Screen**: Complete specifications including dynamic image thumbnail gallery, pricing, discount calculations, ratings, stock counts, shipping, warranty, and return policies.
- **Comprehensive UI States**:
  - Polished Shimmer / Skeleton layout during initial loading.
  - Full-screen error views with interactive retry buttons.
  - Distinct empty states for empty catalogs vs. zero search results.
  - Inline bottom loaders and error banners for pagination.
- **Network Image Caching**: Image caching with placeholder spinners and broken-image fallbacks via `cached_network_image`.

---

## 3. Architecture Explanation

The project is structured according to **Clean Architecture** principles divided into three isolated layers:

```
┌────────────────────────────────────────────────────────┐
│                   Presentation Layer                   │
│  Pages, Reusable Widgets, Cubits & Immutable States    │
└───────────────────────────┬────────────────────────────┘
                            │ depends on Domain
┌───────────────────────────▼────────────────────────────┐
│                      Domain Layer                      │
│   Entities, Repository Interfaces & Domain Use Cases   │
│         (Zero dependencies on Flutter or Dio)          │
└───────────────────────────▲────────────────────────────┘
                            │ implemented by Data
┌───────────────────────────┴────────────────────────────┐
│                       Data Layer                       │
│    Data Models, Remote Data Sources & Repositories     │
│        (Safe JSON parsing & Failure mapping)           │
└────────────────────────────────────────────────────────┘
```

### Presentation Pattern: View -> Section -> Widget
- **Views (`Pages`)**: Compose modular screen sections and handle route-level lifecycle.
- **Sections**: Connect UI state from Cubits and dispatch user events.
- **Widgets**: Pure, reusable presentation components that receive data via constructor parameters and contain zero business logic or API calls.

### Unified Functional Response Pattern: `ApiResult<T>`
Repositories return an `ApiResult<T>` sealed class:
```dart
result.fold(
  (failure) => handleFailure(failure),
  (data) => handleSuccess(data),
);
```

---

## 4. Folder Structure

```
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

## 5. Packages Used & Rationale

| Package | Purpose & Rationale |
|---|---|
| `flutter_bloc` | Enterprise-grade state management via `Cubit`, ensuring deterministic unidirectional data flow and clean separation of UI from business logic. |
| `dio` | Powerful HTTP client providing connection/receive timeouts, request interceptors, cancel tokens, and granular exception handling. |
| `get_it` | High-performance, lightweight service locator for Clean Architecture dependency injection. |
| `go_router` | Declarative routing supporting path parameters (`/products/:id`), deep linking, and smooth navigation stack handling. |
| `equatable` | Value-based equality comparison for immutable states, entities, and failure objects, avoiding unnecessary widget rebuilds. |
| `cached_network_image` | High-performance network image caching with placeholder spinners, memory management, and error fallbacks. |
| `flutter_screenutil` | Responsive design adapter enabling scalable sizing across multiple screen densities and aspect ratios. |
| `bloc_test` *(dev)* | Standardized testing framework for Bloc and Cubit states and act/expect verification. |
| `mocktail` *(dev)* | Type-safe Dart mocking library without code generation requirements. |

---

## 6. API Endpoints

Base URL: `https://dummyjson.com`

- **Get Products**: `GET /products?limit=20&skip=0`
  - Fetches paginated catalog products.
- **Search Products**: `GET /products/search?q={query}&limit=20&skip=0`
  - Server-side text search with pagination.
- **Product Details**: `GET /products/{id}`
  - Fetches single product specifications by numerical ID.

---

## 7. Search Debouncing & Pagination Strategy

### Search Debouncing (350ms)
- User typing is captured by `ProductSearchField` and passed to `ProductsCubit.onSearchChanged`.
- Leading/trailing whitespace is trimmed. If the trimmed text matches the active search query, no request is sent.
- If the text is empty, search mode is immediately exited, the query is cleared, and the default products listing is re-fetched.
- Non-empty input triggers a 350ms timer (`searchDebounceDuration`). Each subsequent keystroke resets the timer, preventing server spam.

### Preventing Stale Responses
- When a search or refresh is initiated:
  1. Any active Dio `CancelToken` is cancelled immediately.
  2. A new `CancelToken` is initialized.
  3. An internal `_requestId` counter is incremented.
- When the asynchronous network call completes:
  - If `currentRequestId != _requestId` or `isClosed` is true, the response is discarded.
  - This eliminates race conditions where an older, slower search query finishes after a faster, newer one.

### Infinite Scrolling Pagination
- `ProductGrid` attaches a listener to its `ScrollController`.
- When `maxScrollExtent - currentScroll <= 300.0`, `onLoadMore` is dispatched.
- Guards prevent duplicate concurrent pagination calls:
  - Does not trigger if `paginationStatus == PaginationStatus.loading`.
  - Does not trigger if `hasMore == false`.
  - Does not trigger if full screen is already refreshing or loading.
- Successful pagination appends new products to the existing list: `[...state.products, ...response.products]`.
- If pagination fails:
  - The already loaded products remain displayed on screen.
  - The bottom indicator transitions to an inline error card with an interactive **Retry** button.

---

## 8. Setup & Run Instructions

### Prerequisites
- Flutter SDK `^3.10.0` or higher
- Dart SDK `^3.10.0` or higher

### Step 1: Clone and navigate to project root
```bash
cd flutter_task
```

### Step 2: Install dependencies
```bash
flutter pub get
```

### Step 3: Run the application
```bash
# To run on connected device or emulator:
flutter run

# To run on Chrome/Web:
flutter run -d chrome

# To run on Windows desktop:
flutter run -d windows
```

---

## 9. Testing Instructions

All unit and widget tests are deterministic and use `mocktail` to mock repositories and use cases.

### Run all automated tests:
```bash
flutter test
```

### Test Suite Coverage:
- **`ProductModel JSON Parsing`**:
  - Full JSON parsing into `ProductModel` and `ProductEntity`.
  - Missing and unexpected optional field handling.
  - Exception throwing on missing/invalid product IDs.
  - Discounted price calculations.
  - `ProductsResponseModel` pagination metadata parsing.
- **`ProductRepositoryImpl`**:
  - Success mapping to `ApiSuccess<ProductsResponseEntity>`.
  - Mapping `NetworkException` to `NetworkFailure`.
  - Mapping `ServerException` to `ServerFailure` with HTTP status code.
  - Mapping `TimeoutException` to `TimeoutFailure`.
  - Mapping `NotFoundException` to `NotFoundFailure`.
  - Mapping `ParsingException` to `ParsingFailure`.
- **`ProductsCubit`**:
  - Initial product loading success emitting `[loading, success]`.
  - Initial loading failure emitting `[loading, error]`.
  - Successful search emitting `[loading, success]`.
  - Empty search emitting `[loading, empty]`.
  - Pagination appending products without resetting existing items.
  - Pagination failure preserving existing loaded products and setting error status.
  - Prevention of duplicate concurrent pagination requests.
  - Ignoring stale search results when a newer query resolves first.
- **`ProductDetailsCubit`**:
  - Details loading success and failure.
  - Retrying detail loading by product ID.
- **`ProductsExplorerApp` Smoke Test**:
  - Top-level widget pump and app bar rendering.

### Code Quality & Static Analysis:
```bash
dart format --output=none --set-exit-if-changed lib test
flutter analyze
```
#   P R O D U C T S _ E X P L O R E R  
 