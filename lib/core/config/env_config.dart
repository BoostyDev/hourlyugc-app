/// Configuración de variables de entorno y API keys
/// 
/// IMPORTANTE: En producción, estas keys deberían venir de:
/// - flutter_dotenv
/// - Firebase Remote Config
/// - Compilación con --dart-define
class EnvConfig {
  // Google Maps / Places API
  // Obtén tu API key en: https://console.cloud.google.com/apis/credentials
  // Habilita: Places API, Maps SDK for Android/iOS
  static const String googleMapsApiKey = String.fromEnvironment(
    'GOOGLE_MAPS_API_KEY',
    defaultValue: 'AIzaSyDbFF1q6ZsgJXeX2ex6CVx4KL_KW_IpN4k', // API key de producción
  );
  
  // LinkedIn Scraping API (backend existente)
  static const String linkedInApiUrl = 
    'https://us-central1-postprofit-a4a46.cloudfunctions.net/api/scrapingdog-linkedin';
  
  // Firestore check LinkedIn exists
  static const String checkLinkedInUrl = 
    'https://us-central1-postprofit-a4a46.cloudfunctions.net/api/check-linkedin-exists';
  
  /// Verifica si Google Maps API está configurado
  static bool get hasGoogleMapsKey => googleMapsApiKey.isNotEmpty;
}

