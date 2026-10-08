import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';
import '../../../data/mock_data.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final filtered = mockFaqs.where((f) {
      return _query.isEmpty ||
          f.question.toLowerCase().contains(_query.toLowerCase()) ||
          f.answer.toLowerCase().contains(_query.toLowerCase());
    }).toList();

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title:
            Text('FAQ', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FREQUENTLY ASKED QUESTIONS',
                style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5),
              ),
              const SizedBox(height: 8),
              Text(
                'Everything you need to know about the BoldKit Flutter design system.',
                style:
                    GoogleFonts.outfit(fontSize: 15, color: t.mutedForeground),
              ),
              const SizedBox(height: 24),
              BkInput(
                hint: 'SEARCH QUESTIONS...',
                prefix: Icon(Icons.search, color: t.foreground),
                onChanged: (v) => setState(() => _query = v),
              ),
              const SizedBox(height: 28),
              BkAccordion(
                allowMultiple: true,
                items: filtered.map((f) {
                  return BkAccordionItem(
                    title: f.question,
                    content: Text(
                      f.answer,
                      style: GoogleFonts.outfit(
                          fontSize: 14, color: t.foreground, height: 1.5),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
