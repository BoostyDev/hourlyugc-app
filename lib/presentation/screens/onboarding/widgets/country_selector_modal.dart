import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/utils/country_data.dart';

/// Modal para seleccionar país con búsqueda
class CountrySelectorModal extends StatefulWidget {
  final Country selectedCountry;
  final Function(Country) onCountrySelected;

  const CountrySelectorModal({
    super.key,
    required this.selectedCountry,
    required this.onCountrySelected,
  });

  @override
  State<CountrySelectorModal> createState() => _CountrySelectorModalState();
}

class _CountrySelectorModalState extends State<CountrySelectorModal> {
  final TextEditingController _searchController = TextEditingController();
  List<Country> _filteredCountries = countries;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterCountries(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredCountries = countries;
      } else {
        _filteredCountries = countries
            .where((country) =>
                country.name.toLowerCase().contains(query.toLowerCase()) ||
                country.dialCode.contains(query))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      height: screenHeight * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFC),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // Drag handle
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: const Color(0xFFCBD5E1),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Title
                Text(
                  'Select Country',
                  style: GoogleFonts.plusJakartaSans(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Search bar
                Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: GoogleFonts.plusJakartaSans(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF0F172A),
                      letterSpacing: -0.18,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Search country...',
                      hintStyle: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                        letterSpacing: -0.18,
                      ),
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF94A3B8),
                        size: 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                    ),
                    onChanged: _filterCountries,
                  ),
                ),
              ],
            ),
          ),
          
          // Divider
          Container(
            height: 1,
            color: const Color(0xFFE2E8F0),
          ),
          
          // Country list
          Expanded(
            child: _filteredCountries.isEmpty
                ? Center(
                    child: Text(
                      'No countries found',
                      style: GoogleFonts.plusJakartaSans(
                        fontSize: 16,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: _filteredCountries.length,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemBuilder: (context, index) {
                      final country = _filteredCountries[index];
                      final isSelected =
                          country.code == widget.selectedCountry.code;

                      return InkWell(
                        onTap: () {
                          widget.onCountrySelected(country);
                          Navigator.pop(context);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFFECFDF5)
                                : Colors.transparent,
                          ),
                          child: Row(
                            children: [
                              // Flag
                              Container(
                                width: 28,
                                height: 20,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(4),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                    width: 0.5,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    country.flag,
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              
                              // Country name
                              Expanded(
                                child: Text(
                                  country.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 16,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                    color: const Color(0xFF0F172A),
                                    letterSpacing: -0.18,
                                  ),
                                ),
                              ),
                              
                              // Dial code
                              Text(
                                country.dialCode,
                                style: GoogleFonts.plusJakartaSans(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                  color: const Color(0xFF64748B),
                                  letterSpacing: -0.18,
                                ),
                              ),
                              
                              // Check icon if selected
                              if (isSelected) ...[
                                const SizedBox(width: 12),
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF10B981),
                                  size: 20,
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

