# Onboarding Flow - HourlyUGC

Sistema completo de onboarding multi-paso para creadores, implementado desde los diseños de Figma.

## 📋 Flujo de Pantallas

El flujo de onboarding consta de 10 pasos:

1. **Phone Number** (`phone_number_screen.dart`) - Node 33-682
   - Solicita número de teléfono con código de país
   - Validación de formato

2. **OTP Verification** (`otp_verification_screen.dart`) - Node 33-714
   - 6 campos para código de verificación
   - Opción "Send Again"

3. **Enter Password** (`enter_password_screen.dart`) - Node 33-1783
   - Password y confirmación
   - Toggle para mostrar/ocultar
   - Opción "Skip"

4. **Full Name** (`full_name_screen.dart`) - Node 33-851
   - Input para nombre completo
   - Indicador visual de cursor activo

5. **How You Identify** (`how_identify_screen.dart`) - Node 33-885
   - Opciones: Male, Female, Other, Prefer not to say
   - Selección única con iconos

6. **How Old Are You** (`how_old_screen.dart`) - Node 33-1630
   - Wheel picker para edad (18+)
   - Display de edad seleccionada

7. **Fill Socials** (`fill_socials_screen.dart`) - Node 33-1367
   - Instagram, TikTok, YouTube, Twitter/X
   - Mínimo 2 redes sociales requeridas

8. **Hourly Rate** (`hourly_rate_screen.dart`) - Node 33-750
   - Selector de moneda (USD por defecto)
   - Input numérico para tarifa
   - Formato: XX / hour

9. **How Did You Find Us** (`how_find_us_screen.dart`) - Node 33-1449
   - Opciones: Instagram, TikTok, YouTube, Google, Friends/Family, Other
   - Opción "Skip"

10. **Profile Picture** (`profile_picture_screen.dart`) - Node 33-818
    - Selector de imagen desde galería
    - Preview circular
    - Opcional (puede continuar sin foto)

## 🏗️ Arquitectura

### Estado Global
```dart
onboardingStateProvider // Maneja el estado del flujo completo
```

**Propiedades:**
- `currentStep`: Paso actual (0-9)
- `userData`: Map con todos los datos recopilados
- `isLoading`: Estado de carga

**Métodos:**
- `nextStep()`: Avanza al siguiente paso
- `previousStep()`: Retrocede al paso anterior
- `updateUserData(key, value)`: Guarda datos del usuario
- `completeOnboarding(context)`: Finaliza y guarda en Firestore

### Layout Común

Todas las pantallas usan `OnboardingLayout` que proporciona:
- Header con botón back
- Progress bar (paso X de 10)
- Título y subtítulo
- Área de contenido scrollable
- Botón "Continue" con diseño de Figma

### Diseño del Botón

El botón "Continue" implementa exactamente el diseño de Figma:
- Gradient: `linear-gradient(191.66deg, #9FF7C0 10.58%, #45D27B 37.13%, #129C8D 88.03%)`
- Border: 4px semi-transparente blanco (35% opacity)
- Inner shadows para efecto glossy
- Ellipse shine (top-right)
- Shadow: `0px 7px 15px rgba(5, 5, 20, 0.1)`

## 🎨 Estilos

### Colores
- Background: `#F8FAFC`
- Primary Text: `#0F172A`
- Secondary Text: `#475569`
- Tertiary Text: `#64748B`
- Placeholder: `#94A3B8`
- Border: `#E2E8F0`
- Success: `#059669` / `#16B364`
- White: `#FFFFFF`

### Tipografía
- **Primary Font**: Plus Jakarta Sans
- **Secondary Font**: DM Sans
- Tamaños: 32px (H4), 24px (H5), 16px (Body), 14px (Label)

## 🔄 Navegación

### Integración con Router

```dart
// En app_router.dart
GoRoute(
  path: '/registration',
  builder: (context, state) => const OnboardingFlowScreen(),
),
```

### Flujo de Navegación

1. **Signup** → `/registration` (inicia onboarding)
2. **Onboarding** → 10 pasos secuenciales
3. **Complete** → `/creator/home` (dashboard)

### Manejo de Estado

- Cada pantalla guarda sus datos en `onboardingStateProvider`
- Al completar, todos los datos se envían a Firestore
- Si el usuario sale, puede retomar desde donde quedó

## 📱 Responsive

Todas las pantallas usan:
```dart
final width = MediaQuery.of(context).size.width;
final scale = width / 402; // Base width de Figma
```

Esto asegura que el diseño se adapte a diferentes tamaños de pantalla manteniendo las proporciones.

## ✅ Validaciones

- **Phone**: No vacío
- **OTP**: 6 dígitos completos
- **Password**: Mínimo 6 caracteres, coincidencia
- **Full Name**: No vacío
- **Gender**: Selección requerida
- **Age**: 18+ años
- **Socials**: Mínimo 2 redes
- **Rate**: Número válido > 0
- **Source**: Selección requerida (o skip)
- **Photo**: Opcional

## 🔧 Uso

```dart
// Navegar al onboarding
context.go('/registration');

// Acceder al estado
final state = ref.watch(onboardingStateProvider);

// Actualizar datos
ref.read(onboardingStateProvider.notifier).updateUserData('key', value);

// Avanzar
ref.read(onboardingStateProvider.notifier).nextStep();
```

## 📝 Notas

- El flujo está diseñado para ser flexible y permitir saltos opcionales
- Algunas pantallas tienen opción "Skip"
- Los datos se guardan incrementalmente
- El diseño sigue exactamente las especificaciones de Figma
- Todos los assets SVG están localizados en `assets/icons/`

## 🚀 Próximos Pasos

- [ ] Implementar integración real con Firebase Auth (phone verification)
- [ ] Conectar con backend para guardar datos
- [ ] Añadir analytics para tracking de conversión
- [ ] Implementar tests unitarios y de integración
- [ ] Añadir animaciones de transición entre pasos

