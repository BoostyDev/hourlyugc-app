import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';
import '../../../core/config/env_config.dart';

/// Pantalla: Where are you based? (Location/City)
/// Usa Google Places API para autocompletado de ciudades
class LocationScreen extends ConsumerStatefulWidget {
  const LocationScreen({super.key});

  @override
  ConsumerState<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends ConsumerState<LocationScreen> {
  final _cityController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedCity;
  String? _selectedCountry;
  String? _selectedCountryCode;
  List<Map<String, dynamic>> _suggestions = [];
  bool _showSuggestions = false;
  bool _isSearching = false;
  String? _sessionToken;

  // Fallback: Lista de ciudades populares si no hay API key
  static const List<Map<String, String>> _popularCities = [
    {'city': 'New York', 'country': 'United States', 'flag': '🇺🇸'},
    {'city': 'Los Angeles', 'country': 'United States', 'flag': '🇺🇸'},
    {'city': 'London', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'city': 'Paris', 'country': 'France', 'flag': '🇫🇷'},
    {'city': 'Berlin', 'country': 'Germany', 'flag': '🇩🇪'},
    {'city': 'Amsterdam', 'country': 'Netherlands', 'flag': '🇳🇱'},
    {'city': 'Madrid', 'country': 'Spain', 'flag': '🇪🇸'},
    {'city': 'Barcelona', 'country': 'Spain', 'flag': '🇪🇸'},
    {'city': 'Milan', 'country': 'Italy', 'flag': '🇮🇹'},
    {'city': 'Toronto', 'country': 'Canada', 'flag': '🇨🇦'},
    {'city': 'Sydney', 'country': 'Australia', 'flag': '🇦🇺'},
    {'city': 'Dubai', 'country': 'UAE', 'flag': '🇦🇪'},
    {'city': 'Singapore', 'country': 'Singapore', 'flag': '🇸🇬'},
    {'city': 'Tokyo', 'country': 'Japan', 'flag': '🇯🇵'},
    {'city': 'Mumbai', 'country': 'India', 'flag': '🇮🇳'},
    {'city': 'São Paulo', 'country': 'Brazil', 'flag': '🇧🇷'},
    {'city': 'Mexico City', 'country': 'Mexico', 'flag': '🇲🇽'},
    {'city': 'Buenos Aires', 'country': 'Argentina', 'flag': '🇦🇷'},
    {'city': 'Stockholm', 'country': 'Sweden', 'flag': '🇸🇪'},
    {'city': 'Dublin', 'country': 'Ireland', 'flag': '🇮🇪'},
    {'city': 'Lisbon', 'country': 'Portugal', 'flag': '🇵🇹'},
    {'city': 'Vienna', 'country': 'Austria', 'flag': '🇦🇹'},
    {'city': 'Zurich', 'country': 'Switzerland', 'flag': '🇨🇭'},
    {'city': 'Copenhagen', 'country': 'Denmark', 'flag': '🇩🇰'},
    {'city': 'Miami', 'country': 'United States', 'flag': '🇺🇸'},
    {'city': 'Chicago', 'country': 'United States', 'flag': '🇺🇸'},
    {'city': 'San Francisco', 'country': 'United States', 'flag': '🇺🇸'},
    {'city': 'Austin', 'country': 'United States', 'flag': '🇺🇸'},
    {'city': 'Valencia', 'country': 'Spain', 'flag': '🇪🇸'},
    {'city': 'Sevilla', 'country': 'Spain', 'flag': '🇪🇸'},
  ];

  @override
  void initState() {
    super.initState();
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
    
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _cityController.text.isEmpty) {
        _showPopularCities();
      }
    });
  }

  @override
  void dispose() {
    _cityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showPopularCities() {
    setState(() {
      _suggestions = _popularCities.take(8).map((city) => {
        'description': '${city['city']}, ${city['country']}',
        'city': city['city'],
        'country': city['country'],
        'flag': city['flag'],
        'isLocal': true,
      }).toList();
      _showSuggestions = true;
    });
  }

  /// Buscar ciudades usando Google Places API
  Future<void> _searchCities(String query) async {
    if (query.isEmpty) {
      _showPopularCities();
      return;
    }

    if (query.length < 2) {
      return;
    }

    // Si no hay API key, usar búsqueda local
    if (!EnvConfig.hasGoogleMapsKey) {
      _searchLocalCities(query);
      return;
    }

    setState(() => _isSearching = true);

    try {
      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/place/autocomplete/json'
        '?input=${Uri.encodeComponent(query)}'
        '&types=(cities)'
        '&key=${EnvConfig.googleMapsApiKey}'
        '&sessiontoken=$_sessionToken'
      );

      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['status'] == 'OK') {
          final predictions = data['predictions'] as List;
          
          setState(() {
            _suggestions = predictions.map((p) {
              final terms = p['terms'] as List? ?? [];
              String city = '';
              String country = '';
              
              if (terms.isNotEmpty) {
                city = terms[0]['value'] ?? '';
              }
              if (terms.length > 1) {
                country = terms.last['value'] ?? '';
              }
              
              return {
                'description': p['description'] ?? '',
                'placeId': p['place_id'],
                'city': city,
                'country': country,
                'flag': _getCountryFlag(country),
                'isLocal': false,
              };
            }).toList();
            _showSuggestions = _suggestions.isNotEmpty;
            _isSearching = false;
          });
        } else if (data['status'] == 'ZERO_RESULTS') {
          // No results from Google, try local search
          _searchLocalCities(query);
        } else {
          // API error, fallback to local
          _searchLocalCities(query);
        }
      } else {
        _searchLocalCities(query);
      }
    } catch (e) {
      // Error, fallback to local search
      _searchLocalCities(query);
    }
  }

  void _searchLocalCities(String query) {
    final results = _popularCities.where((city) {
      final cityName = city['city']!.toLowerCase();
      final countryName = city['country']!.toLowerCase();
      final searchQuery = query.toLowerCase();
      return cityName.contains(searchQuery) || countryName.contains(searchQuery);
    }).toList();

    setState(() {
      _suggestions = results.take(6).map((city) => {
        'description': '${city['city']}, ${city['country']}',
        'city': city['city'],
        'country': city['country'],
        'flag': city['flag'],
        'isLocal': true,
      }).toList();
      _showSuggestions = results.isNotEmpty || query.length >= 2;
      _isSearching = false;
    });
  }

  String _getCountryFlag(String country) {
    final flags = {
      'United States': '🇺🇸', 'USA': '🇺🇸', 'US': '🇺🇸',
      'United Kingdom': '🇬🇧', 'UK': '🇬🇧',
      'Spain': '🇪🇸', 'España': '🇪🇸',
      'France': '🇫🇷',
      'Germany': '🇩🇪', 'Deutschland': '🇩🇪',
      'Italy': '🇮🇹', 'Italia': '🇮🇹',
      'Netherlands': '🇳🇱',
      'Canada': '🇨🇦',
      'Australia': '🇦🇺',
      'Japan': '🇯🇵',
      'Brazil': '🇧🇷', 'Brasil': '🇧🇷',
      'Mexico': '🇲🇽', 'México': '🇲🇽',
      'Argentina': '🇦🇷',
      'India': '🇮🇳',
      'Singapore': '🇸🇬',
      'UAE': '🇦🇪', 'United Arab Emirates': '🇦🇪',
      'Portugal': '🇵🇹',
      'Ireland': '🇮🇪',
      'Sweden': '🇸🇪',
      'Denmark': '🇩🇰',
      'Norway': '🇳🇴',
      'Finland': '🇫🇮',
      'Switzerland': '🇨🇭',
      'Austria': '🇦🇹',
      'Belgium': '🇧🇪',
      'Poland': '🇵🇱',
      'South Korea': '🇰🇷',
      'China': '🇨🇳',
    };
    return flags[country] ?? '🌍';
  }

  void _selectCity(Map<String, dynamic> city) {
    setState(() {
      _selectedCity = city['city'] as String?;
      _selectedCountry = city['country'] as String?;
      _cityController.text = city['description'] as String? ?? '';
      _showSuggestions = false;
    });
    _focusNode.unfocus();
    
    // Generar nuevo session token para la próxima búsqueda
    _sessionToken = DateTime.now().millisecondsSinceEpoch.toString();
  }

  void _handleContinue() {
    final city = _cityController.text.trim();
    if (city.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please enter your city',
        type: SnackbarType.warning,
      );
      return;
    }

    // Save location
    ref.read(onboardingStateProvider.notifier).updateUserData('location', {
      'city': _selectedCity ?? city.split(',').first.trim(),
      'country': _selectedCountry,
      'countryCode': _selectedCountryCode,
      'fullLocation': city,
    });

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "Where are you based?",
      subtitle: "This helps brands find creators in their target regions",
      currentStep: 7,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _cityController.text.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 30),
          
          // City input
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _selectedCity != null 
                    ? const Color(0xFF059669) 
                    : const Color(0xFFE2E8F0),
                width: _selectedCity != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              children: [
                const SizedBox(width: 20),
                Icon(
                  Icons.location_on_outlined,
                  size: 24,
                  color: _selectedCity != null 
                      ? const Color(0xFF059669)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _cityController,
                    focusNode: _focusNode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.18,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search your city...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: -0.18,
                      ),
                    ),
                    onChanged: (value) {
                      _searchCities(value);
                      if (_selectedCity != null && !value.contains(_selectedCity!)) {
                        setState(() {
                          _selectedCity = null;
                          _selectedCountry = null;
                        });
                      }
                    },
                    onTap: () {
                      if (_cityController.text.isEmpty) {
                        _showPopularCities();
                      }
                    },
                  ),
                ),
                if (_isSearching)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Color(0xFF059669),
                      ),
                    ),
                  )
                else if (_selectedCity != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                  )
                else
                  const SizedBox(width: 20),
              ],
            ),
          ),
          
          // Suggestions dropdown
          if (_showSuggestions && _suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 280),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color.fromRGBO(5, 5, 20, 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    indent: 56,
                  ),
                  itemBuilder: (context, index) {
                    final city = _suggestions[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectCity(city),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Text(
                                city['flag'] as String? ?? '🌍',
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      city['city'] as String? ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    Text(
                                      city['country'] as String? ?? '',
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w400,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                size: 14,
                                color: Color(0xFFCBD5E1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ] else if (_cityController.text.isNotEmpty && _suggestions.isEmpty && !_isSearching) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline,
                    color: Color(0xFF64748B),
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'City not found? Continue with "${_cityController.text}"',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          // API status indicator
          if (!EnvConfig.hasGoogleMapsKey) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF3C7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Color(0xFFD97706),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Using offline city list',
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 12,
                      color: const Color(0xFFD97706),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
