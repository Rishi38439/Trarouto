import 'package:flutter/material.dart';
import '../services/mock_data_service.dart';

class TranslationScreen extends StatefulWidget {
  const TranslationScreen({super.key});

  @override
  State<TranslationScreen> createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  String _selectedLang = 'it';
  final TextEditingController _customController = TextEditingController();
  String? _customTranslation;

  void _translateCustom() {
    final query = _customController.text.trim();
    if (query.isEmpty) return;

    if (_selectedLang == 'it') {
      setState(() => _customTranslation = 'Buongiorno, vorrei informazioni per favore ($query)');
    } else {
      setState(() => _customTranslation = 'नमस्ते, मुझे इसके बारे में जानकारी चाहिए ($query)');
    }
  }

  @override
  Widget build(BuildContext context) {
    final phrases = MockDataService.getPhrases(_selectedLang);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF0F172A),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Translation Assistant',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  const Text('Essential situational phrases and phonetic pronunciation guide.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _buildLangButton('Italian (🇮🇹)', 'it'),
                      const SizedBox(width: 8),
                      _buildLangButton('Hindi (🇮🇳)', 'hi'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Translate Text Box
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('QUICK TEXT TRANSLATOR',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _customController,
                          decoration: InputDecoration(
                            hintText: 'Type in English (e.g. Where is the train station?)...',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF147FE8),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        onPressed: _translateCustom,
                        child: const Text('Translate', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  if (_customTranslation != null) ...[
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: const Color(0xFFEFF6FF), borderRadius: BorderRadius.circular(12)),
                      child: Text(_customTranslation!,
                          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color(0xFF1E40AF))),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Phrases
            const Text('SITUATIONAL PHRASEBOOK',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
            const SizedBox(height: 12),

            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: phrases.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, idx) {
                final p = phrases[idx];
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.english, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                          const SizedBox(height: 2),
                          Text(p.translated, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF0F172A))),
                          const SizedBox(height: 2),
                          Text('/${p.phonetic}/',
                              style: const TextStyle(fontSize: 10, color: Color(0xFF147FE8), fontStyle: FontStyle.italic)),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.volume_up, color: Color(0xFF147FE8)),
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Pronouncing: ${p.translated}')),
                          );
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLangButton(String label, String code) {
    final selected = _selectedLang == code;
    return InkWell(
      onTap: () => setState(() => _selectedLang = code),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? Colors.white : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(label,
            style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.bold,
                color: selected ? const Color(0xFF0F172A) : Colors.white70)),
      ),
    );
  }
}
