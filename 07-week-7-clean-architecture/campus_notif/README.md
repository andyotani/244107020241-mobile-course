# Campus Notif

Flutter campus notification app organized with Clean Architecture.

## Source structure

```text
lib/
├── data/
│   ├── datasources/   # Secure token and local notification storage
│   ├── models/        # Data transfer and serialization models
│   ├── repositories/  # Implementations of domain repository contracts
│   └── services/      # Firebase push notification integration
├── domain/
│   ├── entities/      # Application business objects
│   ├── repositories/  # Repository contracts
│   └── usecases/      # Authentication and notification actions
├── presentation/
│   ├── pages/         # Flutter screens
│   └── providers/     # Riverpod state and dependency wiring
├── firebase_options.dart
└── main.dart          # Application composition and router
```

The domain layer has no Flutter or storage dependency. Presentation calls
domain use cases; data implementations satisfy domain repository contracts.

## Run and test

```shell
flutter pub get
flutter test
```
