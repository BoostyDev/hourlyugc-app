# 📦 Assets de Figma - Guía de Descarga

Este proyecto utiliza assets SVG de Figma que se descargan automáticamente.

## 🚀 Descarga Automática de Assets

Para descargar todos los SVGs de Figma automáticamente:

```bash
# Desde el directorio raíz del proyecto hourlyugc
dart run scripts/download_figma_assets.dart
```

Este script descargará:
- ✅ Logo principal (6 1)
- ✅ Icono de fuego 🔥 (Group 7)
- ✅ Icono de corazón ❤️ (Group 14)
- ✅ Ellipse 5 (decoración del botón)
- ✅ Flecha (Arrow)
- ✅ Elementos del shine (Ellipse 7, 8 y Star)

## 📂 Estructura de Assets

```
assets/
├── images/
│   └── hourly_ugc_logo.svg       # Logo principal
└── icons/
    ├── fire.svg                   # Icono de fuego 🔥
    ├── heart.svg                  # Icono de corazón ❤️
    ├── ellipse_5.svg              # Shine del botón
    ├── arrow.svg                  # Flecha
    ├── ellipse_7.svg              # Shine outer glow
    ├── ellipse_8.svg              # Shine inner glow
    └── star.svg                   # Star shape
```

## ⚙️ Configuración Manual

Si prefieres descargar manualmente:

1. Las URLs de Figma están en `lib/core/utils/figma_assets_updated.dart`
2. Descarga cada SVG desde su URL
3. Guarda en la carpeta correspondiente (`assets/images/` o `assets/icons/`)
4. Los nombres deben coincidir con los especificados en `FigmaAssetsUpdated`

## 🔄 Actualización de Assets

Los assets de Figma expiran después de 7 días. Para actualizarlos:

1. Obtén las nuevas URLs desde Figma (usando el MCP tool)
2. Actualiza las URLs en `figma_assets_updated.dart`
3. Re-ejecuta el script de descarga

## ✨ Ventajas de Assets Locales

- 🚀 Carga instantánea (no depende de red)
- 💪 No hay errores de decodificación
- 🎨 Renderizado perfecto de SVG
- 📱 Menor uso de datos
- ⚡ Mejor rendimiento general

## 🛠️ Troubleshooting

Si un asset no carga:
1. Verifica que el archivo existe en la carpeta correcta
2. Comprueba que el nombre coincide con `FigmaAssetsUpdated`
3. Ejecuta `flutter pub get` para actualizar los assets
4. Haz hot restart (`R` en terminal de Flutter)

## 📝 Notas

- Los assets PNG (imágenes de contenido) se cargan desde red con `CachedNetworkImage`
- Los SVG se cargan localmente con `SvgPicture.asset()`
- Si un SVG local falla, hay fallback a emoji o placeholder

