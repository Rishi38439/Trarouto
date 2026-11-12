import 'package:flutter/material.dart';
import '../models/travel_models.dart';
import '../services/mock_data_service.dart';

class ScamVerificationScreen extends StatefulWidget {
  const ScamVerificationScreen({super.key});

  @override
  State<ScamVerificationScreen> createState() => _ScamVerificationScreenState();
}

class _ScamVerificationScreenState extends State<ScamVerificationScreen> {
  final TextEditingController _textController = TextEditingController(
    text: 'Owner requested immediate full payment via crypto / personal Western Union wire transfer. Promised 50% discount if paid within 2 hours. WhatsApp only, no registered office.',
  );
  String _paymentMethod = 'Cryptocurrency / Wire Transfer';
  ScamCheckAssessment? _assessment;

  @override
  void initState() {
    super.initState();
    _runAudit();
  }

  void _runAudit() {
    setState(() {
      _assessment = MockDataService.assessScam(_textController.text, _paymentMethod);
    });
  }

  @override
  Widget build(BuildContext context) {
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
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Travel Scam & Listing Verification',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                  SizedBox(height: 6),
                  Text('Detect suspicious phantom listings, unauthorized brokers, and high-risk wire transfers.',
                      style: TextStyle(color: Color(0xFF94A3B8), fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Form
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('ANALYZE SUSPICIOUS COMMUNICATION',
                      style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _textController,
                    maxLines: 3,
                    decoration: InputDecoration(
                      hintText: 'Paste suspicious quote, hotel booking email, or wire instruction...',
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: _paymentMethod,
                          decoration: InputDecoration(
                            labelText: 'Payment Method',
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            isDense: true,
                          ),
                          onChanged: (val) => _paymentMethod = val,
                        ),
                      ),
                      const SizedBox(width: 12),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0F172A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: _runAudit,
                        icon: const Icon(Icons.security, size: 16),
                        label: const Text('Audit Listing', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Audit Result
            if (_assessment != null) ...[
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('CALCULATED THREAT INDEX',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Color(0xFF64748B))),
                            Text('${_assessment!.riskScore}/100',
                                style: TextStyle(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w900,
                                    color: _assessment!.riskScore >= 60 ? Colors.red.shade700 : Colors.green.shade700)),
                          ],
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _assessment!.riskScore >= 60 ? Colors.red.shade100 : Colors.green.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${_assessment!.riskLevel.toUpperCase()} RISK',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: _assessment!.riskScore >= 60 ? Colors.red.shade900 : Colors.green.shade900),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _assessment!.riskScore >= 60 ? const Color(0xFFFFF1F2) : const Color(0xFFF0FDF4),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(_assessment!.verdict,
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: _assessment!.riskScore >= 60 ? Colors.red.shade900 : Colors.green.shade900)),
                    ),
                    const SizedBox(height: 16),

                    // Risk Signals
                    const Text('OBSERVED RISK SIGNALS',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5, color: Color(0xFF64748B))),
                    const SizedBox(height: 8),

                    ..._assessment!.indicators.map((ind) => Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF8FAFC),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: const Color(0xFFE2E8F0)),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                ind.type == 'danger' ? Icons.error : Icons.check_circle,
                                size: 16,
                                color: ind.type == 'danger' ? Colors.red : Colors.green,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(ind.label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                    Text(ind.description, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )),
                    const SizedBox(height: 12),

                    // Disclaimer
                    Text(_assessment!.disclaimer,
                        style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8), fontStyle: FontStyle.italic, height: 1.3)),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
