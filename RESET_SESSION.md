# 🔄 Cómo Resetear la Sesión de Registro

Si tienes una sesión antigua del registration y quieres empezar de nuevo con el nuevo flujo de onboarding, tienes varias opciones:

## Opción 1: Usar la Pantalla de Debug (Recomendado) ✅

He creado una pantalla especial para desarrollo que te permite resetear fácilmente:

### Acceder a Debug Screen:

```dart
// En tu navegador o código, navega a:
context.go('/debug');

// O desde terminal/URL:
// http://localhost:XXXX/debug
```

### Opciones Disponibles:

1. **Reset Registration** 🔄
   - Marca tu registro como incompleto
   - Te redirige automáticamente al nuevo flujo de onboarding
   - Mantiene tu cuenta de Firebase Auth
   - **Usa esta opción si solo quieres probar el onboarding de nuevo**

2. **Clear User Data** 🗑️
   - Elimina TODOS los datos del usuario en Firestore
   - Empiezas completamente desde cero
   - Tu cuenta de Firebase Auth se mantiene
   - **Usa esta opción si quieres un reset completo**

3. **Logout** 🚪
   - Cierra sesión completamente
   - Vuelves a la pantalla de onboarding inicial

## Opción 2: Usar Firebase Console

1. Ve a [Firebase Console](https://console.firebase.google.com)
2. Selecciona tu proyecto
3. Ve a **Firestore Database**
4. Busca la colección `users`
5. Encuentra tu documento de usuario
6. Edita el campo `registrationCompleted` y cámbialo a `false`
7. Recarga la app

## Opción 3: Usar Flutter DevTools

```dart
// En tu código, puedes llamar directamente:
await ref.read(loginProvider.notifier).resetRegistration();

// O para limpiar todo:
await ref.read(loginProvider.notifier).clearUserData();
```

## Opción 4: Comando desde Terminal (Firebase CLI)

Si tienes Firebase CLI instalado:

```bash
# Actualizar el campo registrationCompleted
firebase firestore:update users/TU_USER_ID registrationCompleted=false

# O eliminar el documento completo
firebase firestore:delete users/TU_USER_ID
```

## 🎯 Flujo Recomendado para Testing

1. **Primera vez**: Usa "Clear User Data" para empezar limpio
2. **Probar onboarding**: Usa "Reset Registration" cada vez que quieras volver a probarlo
3. **Cambiar de cuenta**: Usa "Logout" y crea una nueva cuenta

## 📱 Acceso Rápido a Debug Screen

Puedes añadir un botón temporal en cualquier pantalla:

```dart
// Ejemplo: En creator_home_screen.dart
FloatingActionButton(
  onPressed: () => context.go('/debug'),
  child: Icon(Icons.bug_report),
)
```

## ⚠️ Importante

- La pantalla de Debug es **solo para desarrollo**
- No la incluyas en producción
- Los cambios en Firestore son permanentes
- "Clear User Data" NO elimina la cuenta de Firebase Auth, solo los datos en Firestore

## 🔐 Seguridad

Para producción, asegúrate de:
1. Remover la ruta `/debug` del router
2. O añadir validación de entorno:

```dart
// En app_router.dart
if (kDebugMode) {
  GoRoute(
    path: '/debug',
    builder: (context, state) => const DebugScreen(),
  ),
}
```

## 📞 Soporte

Si tienes problemas:
1. Verifica que estés autenticado (Firebase Auth)
2. Revisa los logs de Flutter
3. Verifica la consola de Firestore
4. Asegúrate de tener permisos de escritura en Firestore

---

**Última actualización**: Diciembre 2024
**Versión**: 1.0.0

