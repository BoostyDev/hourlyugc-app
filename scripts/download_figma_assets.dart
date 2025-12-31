import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;

/// Script para descargar todos los assets SVG de Figma automáticamente
/// Uso: dart run scripts/download_figma_assets.dart
void main() async {
  print('🎨 Descargando assets de Figma...\n');

  final assets = {
    // SVGs del logo y decoraciones
    'Logo (6 1)': {
      'url': 'https://www.figma.com/api/mcp/asset/fa786fa5-408f-470c-88f9-f1decc6380b8',
      'path': 'assets/images/hourly_ugc_logo.svg',
    },
    'Fire Icon (Group 7)': {
      'url': 'https://www.figma.com/api/mcp/asset/388272c7-7364-40ae-ab8d-a154bffc9114',
      'path': 'assets/icons/fire.svg',
    },
    'Heart Icon (Group 14)': {
      'url': 'https://www.figma.com/api/mcp/asset/e6b740b9-814e-4366-8423-9402a3defb66',
      'path': 'assets/icons/heart.svg',
    },
    'Ellipse 5 (Button)': {
      'url': 'https://www.figma.com/api/mcp/asset/b8afb81e-ce5c-46f6-92e2-880229319db8',
      'path': 'assets/icons/ellipse_5.svg',
    },
    'Arrow': {
      'url': 'https://www.figma.com/api/mcp/asset/fe76cb22-f110-495b-bb44-ec0e464a3e62',
      'path': 'assets/icons/arrow.svg',
    },
    'Ellipse 7 (Shine)': {
      'url': 'https://www.figma.com/api/mcp/asset/87c5712a-5c21-4cc7-8cbe-2d8076a2bb7f',
      'path': 'assets/icons/ellipse_7.svg',
    },
    'Ellipse 8 (Shine)': {
      'url': 'https://www.figma.com/api/mcp/asset/1a1ea21b-6b11-45dd-967e-70c418e9be1d',
      'path': 'assets/icons/ellipse_8.svg',
    },
    'Group 15 (Star)': {
      'url': 'https://www.figma.com/api/mcp/asset/1cf27135-88f1-403c-a095-14bdeca37ab6',
      'path': 'assets/icons/star.svg',
    },
  };

  int successCount = 0;
  int errorCount = 0;

  for (var entry in assets.entries) {
    final name = entry.key;
    final url = entry.value['url'] as String;
    final path = entry.value['path'] as String;

    try {
      print('📥 Descargando: $name');
      print('   URL: $url');
      print('   Guardando en: $path');

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final file = File(path);
        await file.parent.create(recursive: true);
        
        // Verificar si es SVG
        final content = response.body;
        if (content.contains('<svg') || content.contains('<?xml')) {
          await file.writeAsString(content);
          print('   ✅ Descargado correctamente\n');
          successCount++;
        } else {
          print('   ⚠️  No es un SVG válido, guardando como PNG/otros\n');
          await file.writeAsBytes(response.bodyBytes);
          successCount++;
        }
      } else {
        print('   ❌ Error: ${response.statusCode}\n');
        errorCount++;
      }
    } catch (e) {
      print('   ❌ Error al descargar: $e\n');
      errorCount++;
    }

    // Pequeña pausa para no saturar la API
    await Future.delayed(const Duration(milliseconds: 500));
  }

  print('\n' + '=' * 50);
  print('✨ Proceso completado!');
  print('   ✅ Exitosos: $successCount');
  print('   ❌ Errores: $errorCount');
  print('=' * 50);

  if (successCount > 0) {
    print('\n💡 No olvides actualizar figma_assets_updated.dart');
    print('   con las rutas locales de los assets descargados.');
  }
}

