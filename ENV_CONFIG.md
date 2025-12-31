# Environment Configuration

## Variables de Entorno Necesarias

Si usas variables de entorno (opcional), crea un archivo `.env` con:

```env
# Firebase Configuration (Get from Firebase Console)
FIREBASE_API_KEY=your_firebase_api_key_here
FIREBASE_PROJECT_ID=your_project_id_here
FIREBASE_STORAGE_BUCKET=your_storage_bucket_here
FIREBASE_MESSAGING_SENDER_ID=your_sender_id_here
FIREBASE_APP_ID=your_app_id_here

# API Configuration
API_BASE_URL=http://localhost:3000/api

# Stripe (for payments)
STRIPE_PUBLISHABLE_KEY=your_stripe_publishable_key_here

# Social Media APIs (optional)
APIFY_API_KEY=your_apify_key_here

# Google Maps (optional)
GOOGLE_MAPS_API_KEY=your_maps_key_here
```

## Configuración Actual

Actualmente, la configuración está hardcodeada en:
- `lib/core/config/firebase_config.dart` - Para Firebase
- `lib/core/constants/app_constants.dart` - Para API base URL

## Usar Variables de Entorno (Opcional)

Si quieres usar variables de entorno:

1. Instala el package:
```bash
flutter pub add flutter_dotenv
```

2. Agrega al `pubspec.yaml`:
```yaml
assets:
  - .env
```

3. Carga el archivo en `main.dart`:
```dart
import 'package:flutter_dotenv/flutter_dotenv.dart';

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  // ...resto del código
}
```

4. Usa las variables:
```dart
String apiKey = dotenv.env['FIREBASE_API_KEY'] ?? '';
```

## Nota de Seguridad

**NUNCA subas archivos .env a Git**

Asegúrate de que `.env` esté en `.gitignore` (ya debería estar).

