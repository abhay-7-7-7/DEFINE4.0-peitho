import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_motion.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({super.key});

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    BkMotion.hapticClick();
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      BkToastManager.show(
        context,
        message: 'PLEASE PROVIDE BOTH NAME AND EMAIL',
        variant: BkToastVariant.warning,
      );
      return;
    }
    BkToastManager.show(
      context,
      message: 'MESSAGE TRANSMITTED SUCCESSFULLY!',
      variant: BkToastVariant.success,
    );
    _nameController.clear();
    _emailController.clear();
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('CONTACT',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isWide = constraints.maxWidth > 800;

            final infoSection = Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'GET IN TOUCH',
                  style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Have questions about custom licenses, consulting, or component development? Let\'s talk.',
                  style: GoogleFonts.outfit(
                      fontSize: 15, color: t.mutedForeground),
                ),
                const SizedBox(height: 24),
                _buildInfoCard(
                    'EMAIL', 'hello@boldkit.dev', Icons.email_outlined, t),
                const SizedBox(height: 12),
                _buildInfoCard('OFFICE', '100 Brutalist Way, San Francisco, CA',
                    Icons.location_on_outlined, t),
                const SizedBox(height: 12),
                _buildInfoCard(
                    'COMMUNITY', 'discord.gg/boldkit', Icons.forum_outlined, t),
              ],
            );

            final formSection = BkCard(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text('SEND A MESSAGE',
                        style: GoogleFonts.outfit(
                            fontSize: 18, fontWeight: FontWeight.w900)),
                    const SizedBox(height: 20),
                    BkInput(
                      controller: _nameController,
                      label: 'YOUR NAME',
                      hint: 'Alex Chen',
                    ),
                    const SizedBox(height: 16),
                    BkInput(
                      controller: _emailController,
                      label: 'YOUR EMAIL',
                      hint: 'alex@example.com',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    BkTextarea(
                      controller: _messageController,
                      label: 'YOUR MESSAGE',
                      hint: 'Tell us about your project...',
                      minLines: 4,
                    ),
                    const SizedBox(height: 24),
                    BkButton(
                      label: 'TRANSMIT MESSAGE',
                      variant: BkButtonVariant.primary,
                      size: BkButtonSize.lg,
                      onPressed: _handleSubmit,
                    ),
                  ],
                ),
              ),
            );

            if (isWide) {
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 5, child: infoSection),
                  const SizedBox(width: 32),
                  Expanded(flex: 6, child: formSection),
                ],
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                infoSection,
                const SizedBox(height: 32),
                formSection,
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon, BkTokens t) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [
          BoxShadow(color: t.shadowColor, offset: const Offset(3, 3)),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            color: t.accent,
            child: Icon(icon, color: t.accentForeground, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: t.mutedForeground)),
                const SizedBox(height: 2),
                Text(value,
                    style: GoogleFonts.outfit(
                        fontSize: 13, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
