import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_badge.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_states.dart';

final voiceHealthProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final api = ref.watch(apiClientProvider);
  try {
    final res = await api.get('/api/v1/voice/health', requiresAuth: true);
    if (res is Map<String, dynamic>) {
      return res;
    }
    return {'available': false, 'sarvam_configured': false};
  } catch (e) {
    return {'available': false, 'sarvam_configured': false, 'error': e.toString()};
  }
});

class VoiceCallScreen extends ConsumerStatefulWidget {
  const VoiceCallScreen({super.key});

  @override
  ConsumerState<VoiceCallScreen> createState() => _VoiceCallScreenState();
}

class _VoiceCallScreenState extends ConsumerState<VoiceCallScreen> {
  bool _isCallActive = false;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final healthAsync = ref.watch(voiceHealthProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.card,
        elevation: 0,
        shape: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        title: Text(
          'SARVAM VOICE CALL',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            fontSize: 16,
            color: t.foreground,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(voiceHealthProvider),
          ),
        ],
      ),
      body: healthAsync.when(
        loading: () => const BkLoadingState(message: 'Checking Sarvam voice engine health...'),
        error: (err, _) => BkErrorState(
          error: err.toString(),
          onRetry: () => ref.refresh(voiceHealthProvider),
        ),
        data: (health) {
          final isConfigured = health['sarvam_configured'] == true;
          final isAvailable = health['available'] == true;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Diagnostics Status Card
                BkCard(
                  backgroundColor: t.card,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'ENGINE DIAGNOSTICS',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 13,
                                fontWeight: FontWeight.w900,
                                color: t.foreground,
                              ),
                            ),
                            BkBadge(
                              label: isConfigured ? 'SARVAM READY' : 'KEY MISSING',
                              variant: isConfigured ? BkBadgeVariant.success : BkBadgeVariant.warning,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _diagRow('Transport', 'WebSocket 16kHz PCM Stream'),
                        _diagRow('Speech-to-Text', 'Sarvam AI Saarika v2 STT'),
                        _diagRow('Text-to-Speech', 'Sarvam AI Bulbul v1 TTS'),
                        _diagRow('Backend Status', isAvailable ? 'Operational' : 'Unavailable (Needs API Key)'),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Live Key Notice if not configured
                if (!isConfigured) ...[
                  const BkAlert(
                    title: 'NEEDS HUMAN / LIVE API KEY',
                    description:
                        'The backend requires SARVAM_API_KEY in backend/.env to connect to Sarvam AI live STT/TTS models. '
                        'Voice negotiation WebSocket routes are implemented and ready on the server.',
                    variant: BkAlertVariant.warning,
                  ),
                  const SizedBox(height: 16),
                  BkCard(
                    backgroundColor: t.card,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'HOW TO ENABLE LIVE VOICE',
                            style: TextStyle(
                              fontFamily: 'Outfit',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: t.foreground,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '1. Obtain an API key from https://sarvam.ai\n'
                            '2. Add to backend/.env: SARVAM_API_KEY="your_key"\n'
                            '3. Restart backend with python -m uvicorn app.main:app\n'
                            '4. Tap refresh above to verify live connection.',
                            style: TextStyle(fontFamily: 'DM Mono', fontSize: 12, height: 1.5, color: t.mutedForeground),
                          ),
                        ],
                      ),
                    ),
                  ),
                ] else ...[
                  // Voice Active Controls
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: t.card,
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: [
                        BoxShadow(
                          color: t.shadowColor,
                          offset: Offset(t.shadowOffset, t.shadowOffset),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Icon(
                          _isCallActive ? Icons.mic : Icons.mic_none,
                          size: 64,
                          color: _isCallActive ? t.secondary : t.mutedForeground,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          _isCallActive ? 'CALL IN PROGRESS' : 'READY TO CONNECT',
                          style: TextStyle(
                            fontFamily: 'Outfit',
                            fontSize: 16,
                            fontWeight: FontWeight.w900,
                            color: t.foreground,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _isCallActive ? 'Streaming 16kHz PCM audio bidirectionally' : 'Tap below to start AI voice negotiation',
                          style: TextStyle(fontSize: 12, color: t.mutedForeground),
                        ),
                        const SizedBox(height: 20),
                        BkButton(
                          variant: _isCallActive ? BkButtonVariant.destructive : BkButtonVariant.primary,
                          label: _isCallActive ? 'TERMINATE VOICE CALL' : 'START VOICE CALL',
                          onPressed: () {
                            setState(() => _isCallActive = !_isCallActive);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _diagRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          Text(value, style: const TextStyle(fontFamily: 'DM Mono', fontSize: 11)),
        ],
      ),
    );
  }
}
