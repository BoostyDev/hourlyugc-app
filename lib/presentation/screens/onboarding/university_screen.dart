import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'widgets/onboarding_layout.dart';
import 'onboarding_flow.dart';
import '../../widgets/custom_snackbar.dart';

/// Pantalla: University
/// Con autocompletado de universidades populares
class UniversityScreen extends ConsumerStatefulWidget {
  const UniversityScreen({super.key});

  @override
  ConsumerState<UniversityScreen> createState() => _UniversityScreenState();
}

class _UniversityScreenState extends ConsumerState<UniversityScreen> {
  final _universityController = TextEditingController();
  final _focusNode = FocusNode();
  String? _selectedUniversity;
  List<Map<String, String>> _suggestions = [];
  bool _showSuggestions = false;

  // Lista de universidades populares
  static const List<Map<String, String>> _popularUniversities = [
    // USA
    {'name': 'Harvard University', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'Stanford University', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'MIT', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'Yale University', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'Columbia University', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'UCLA', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'USC', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'NYU', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'University of Texas at Austin', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'University of Michigan', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'UC Berkeley', 'country': 'United States', 'flag': '🇺🇸'},
    {'name': 'University of Florida', 'country': 'United States', 'flag': '🇺🇸'},
    // UK
    {'name': 'University of Oxford', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'University of Cambridge', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'Imperial College London', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'UCL', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'King\'s College London', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    {'name': 'University of Manchester', 'country': 'United Kingdom', 'flag': '🇬🇧'},
    // Spain
    {'name': 'Universidad Complutense de Madrid', 'country': 'Spain', 'flag': '🇪🇸'},
    {'name': 'Universidad de Barcelona', 'country': 'Spain', 'flag': '🇪🇸'},
    {'name': 'Universidad Autónoma de Madrid', 'country': 'Spain', 'flag': '🇪🇸'},
    {'name': 'IE University', 'country': 'Spain', 'flag': '🇪🇸'},
    {'name': 'ESADE', 'country': 'Spain', 'flag': '🇪🇸'},
    {'name': 'Universidad de Valencia', 'country': 'Spain', 'flag': '🇪🇸'},
    // Germany
    {'name': 'Technical University of Munich', 'country': 'Germany', 'flag': '🇩🇪'},
    {'name': 'LMU Munich', 'country': 'Germany', 'flag': '🇩🇪'},
    {'name': 'Humboldt University of Berlin', 'country': 'Germany', 'flag': '🇩🇪'},
    // France
    {'name': 'Sorbonne University', 'country': 'France', 'flag': '🇫🇷'},
    {'name': 'Sciences Po', 'country': 'France', 'flag': '🇫🇷'},
    {'name': 'HEC Paris', 'country': 'France', 'flag': '🇫🇷'},
    // Netherlands
    {'name': 'University of Amsterdam', 'country': 'Netherlands', 'flag': '🇳🇱'},
    {'name': 'TU Delft', 'country': 'Netherlands', 'flag': '🇳🇱'},
    // Canada
    {'name': 'University of Toronto', 'country': 'Canada', 'flag': '🇨🇦'},
    {'name': 'McGill University', 'country': 'Canada', 'flag': '🇨🇦'},
    {'name': 'UBC', 'country': 'Canada', 'flag': '🇨🇦'},
    // Australia
    {'name': 'University of Melbourne', 'country': 'Australia', 'flag': '🇦🇺'},
    {'name': 'University of Sydney', 'country': 'Australia', 'flag': '🇦🇺'},
    // Others
    {'name': 'ETH Zurich', 'country': 'Switzerland', 'flag': '🇨🇭'},
    {'name': 'National University of Singapore', 'country': 'Singapore', 'flag': '🇸🇬'},
    {'name': 'University of Tokyo', 'country': 'Japan', 'flag': '🇯🇵'},
    {'name': 'Seoul National University', 'country': 'South Korea', 'flag': '🇰🇷'},
    {'name': 'Tsinghua University', 'country': 'China', 'flag': '🇨🇳'},
    {'name': 'IIT Delhi', 'country': 'India', 'flag': '🇮🇳'},
    {'name': 'USP', 'country': 'Brazil', 'flag': '🇧🇷'},
    {'name': 'UNAM', 'country': 'Mexico', 'flag': '🇲🇽'},
  ];

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      if (_focusNode.hasFocus && _universityController.text.isEmpty) {
        setState(() {
          _showSuggestions = true;
          _suggestions = _popularUniversities.take(8).toList();
        });
      }
    });
  }

  @override
  void dispose() {
    _universityController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _searchUniversities(String query) {
    if (query.isEmpty) {
      setState(() {
        _suggestions = _popularUniversities.take(8).toList();
        _showSuggestions = true;
      });
      return;
    }

    final results = _popularUniversities.where((uni) {
      final uniName = uni['name']!.toLowerCase();
      final countryName = uni['country']!.toLowerCase();
      final searchQuery = query.toLowerCase();
      return uniName.contains(searchQuery) || countryName.contains(searchQuery);
    }).toList();

    setState(() {
      _suggestions = results.take(6).toList();
      _showSuggestions = results.isNotEmpty || query.length >= 2;
    });
  }

  void _selectUniversity(Map<String, String> uni) {
    setState(() {
      _selectedUniversity = uni['name'];
      _universityController.text = uni['name']!;
      _showSuggestions = false;
    });
    _focusNode.unfocus();
  }

  void _handleContinue() {
    final university = _universityController.text.trim();
    if (university.isEmpty) {
      CustomSnackbar.show(
        context,
        message: 'Please enter your university',
        type: SnackbarType.warning,
      );
      return;
    }

    // Save university
    ref.read(onboardingStateProvider.notifier).updateUserData('university', university);

    // Go to next step
    ref.read(onboardingStateProvider.notifier).nextStep();
  }

  void _handleBack() {
    ref.read(onboardingStateProvider.notifier).previousStep();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingLayout(
      title: "Which university do you attend?",
      subtitle: "Start typing to search for your university",
      currentStep: 10,
      totalSteps: 14,
      onBack: _handleBack,
      onContinue: _handleContinue,
      isContinueEnabled: _universityController.text.isNotEmpty,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // University input
          Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: _selectedUniversity != null 
                    ? const Color(0xFF059669) 
                    : const Color(0xFFE2E8F0),
                width: _selectedUniversity != null ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const SizedBox(width: 16),
                Icon(
                  Icons.school_outlined,
                  size: 24,
                  color: _selectedUniversity != null 
                      ? const Color(0xFF059669)
                      : const Color(0xFF64748B),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _universityController,
                    focusNode: _focusNode,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.18,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search your university...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: -0.18,
                      ),
                    ),
                    onChanged: (value) {
                      _searchUniversities(value);
                      // Reset selected if user is typing
                      if (_selectedUniversity != null && value != _selectedUniversity) {
                        setState(() {
                          _selectedUniversity = null;
                        });
                      }
                    },
                    onTap: () {
                      if (_universityController.text.isEmpty) {
                        _searchUniversities('');
                      }
                    },
                  ),
                ),
                if (_selectedUniversity != null)
                  const Padding(
                    padding: EdgeInsets.only(right: 16),
                    child: Icon(
                      Icons.check_circle,
                      color: Color(0xFF059669),
                      size: 20,
                    ),
                  )
                else
                  const SizedBox(width: 16),
              ],
            ),
          ),
          
          // Suggestions dropdown
          if (_showSuggestions && _suggestions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              constraints: const BoxConstraints(maxHeight: 300),
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
                    final uni = _suggestions[index];
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () => _selectUniversity(uni),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          child: Row(
                            children: [
                              Text(
                                uni['flag']!,
                                style: const TextStyle(fontSize: 24),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      uni['name']!,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 15,
                                        fontWeight: FontWeight.w500,
                                        color: const Color(0xFF0F172A),
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      uni['country']!,
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
          ] else if (_universityController.text.length >= 2 && _suggestions.isEmpty) ...[
            const SizedBox(height: 12),
            // No results - user can still continue with custom university
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
                      'Not in list? Continue with "${_universityController.text}"',
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
        ],
      ),
    );
  }
}
