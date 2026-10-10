# Peitho Mobile

Peitho Mobile is a Flutter application for TradeMind's seller-assisted product negotiation workflow. It provides authenticated tools for sellers and a separate, token-based chat experience for buyers joining a negotiation.

The app connects to a TradeMind-compatible FastAPI backend over HTTP and WebSockets. The backend is not included in this repository.

## Features

### Seller workspace

- Seller registration and sign-in, with authentication state managed in the app.
- Seller dashboard, product catalog, product creation and editing, and product statistics.
- Negotiation meetings, meeting links, callbacks, and live assisted negotiation.
- Autonomous chatbot demo and voice-call experience.
- Business analytics, API key management, email/SMTP configuration, and seller settings.
- Seller-only screens for negotiation details and business information.

### Buyer experience

- Join a negotiation without creating an account by scanning a QR code or entering a join link/token.
- View public negotiation details and chat with the seller in real time.
- Buyer requests use the public, tokenized API flow; seller-only business data belongs in authenticated seller flows, not buyer UI.

### Design system and app foundations

- Neubrutalist visual style adapted from [BoldKit](https://github.com/ANIBIT14/boldkit), including reusable Flutter widgets, strong borders, hard shadows, and high-contrast colors.
- Light and dark themes, responsive layouts, and reusable chart, form, navigation, and feedback components.
- Riverpod for state management and GoRouter for navigation.
- Secure storage for seller credentials, HTTP API integration, and WebSocket support.

## Technology

- Flutter and Dart
- Riverpod
- GoRouter
- REST API: `http`
- Real-time communication: `web_socket_channel`
- Local preferences: `shared_preferences`
- Secure credential storage: `flutter_secure_storage`
- QR scanning: `mobile_scanner`

## Requirements

- Flutter SDK with Dart 3 (the package requires Dart `>=3.0.0 <4.0.0`)
- A running TradeMind-compatible FastAPI backend
- Android Studio or VS Code with a configured Flutter device/emulator, or a supported desktop/web target

## Configure the backend

Set the backend base URL at build/run time with `API_URL`:

```sh
flutter run --dart-define=API_URL=http://127.0.0.1:8000
```

`API_BASE_URL` is also accepted as a fallback compile-time name. If neither is provided, the app uses `http://127.0.0.1:8000`. The active API URL can also be persisted through the app's configuration provider.

For an Android emulator, use the host address reachable from that emulator (commonly `http://10.0.2.2:8000`). For a physical Android device connected over USB, you can use `adb reverse tcp:8000 tcp:8000` and the default loopback URL, or configure the device to reach your development machine over the network. Use your backend's reachable HTTPS URL for a deployed environment.

## Run locally

From the directory containing `pubspec.yaml`:

```sh
flutter pub get
flutter run
```

To select a target explicitly:

```sh
flutter devices
flutter run -d <device-id> --dart-define=API_URL=http://127.0.0.1:8000
```

The app starts in the seller workspace. Sign in or register against a configured backend to use authenticated seller features. Buyers can join using a valid negotiation link or token.

## Run tests

```sh
flutter test
```

The test suite covers reusable widgets, responsive rendering, buyer data models/confidentiality behavior, and join-link parsing.

## Project layout

```text
lib/
  core/                 App configuration, routing, networking, storage, theme, and widgets
  features/
    seller/             Authenticated seller workspace and negotiation tools
    buyer/              Token-based buyer join and live chat
    components/          Reusable widget catalog and component details
    charts/              Chart showcase
    shapes/              Shape gallery and builder
    ascii_effects/       ASCII and visual effects
    theme_builder/       Theme customization
    blocks/              Reusable auth, marketing, settings, and form screens
test/                   Widget, responsive, buyer, and link-parser tests
docs/                   Architecture and design-system port notes
```

## Credits and license

Peitho Mobile is maintained by **Abhay (`abhay-7-7-7`)** and is distributed under the MIT License; see [LICENSE](LICENSE).

The Neubrutalist design system and adapted components are based on [BoldKit](https://github.com/ANIBIT14/boldkit) by Aniruddha Agarwal. The original BoldKit MIT copyright and attribution are retained in the license and relevant design-system documentation. This attribution does not imply that the original BoldKit project or its author is responsible for Peitho Mobile.
