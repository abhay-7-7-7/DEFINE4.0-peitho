import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class BlocksSettingsScreen extends StatefulWidget {
  const BlocksSettingsScreen({super.key});

  @override
  State<BlocksSettingsScreen> createState() => _BlocksSettingsScreenState();
}

class _BlocksSettingsScreenState extends State<BlocksSettingsScreen> {
  int _tabIndex = 0;

  final _nameController = TextEditingController(text: 'Alex Chen');
  final _emailController = TextEditingController(text: 'alex@example.com');
  final _bioController = TextEditingController(text: 'Building bold products with neubrutalism aesthetics.');

  // Notification toggles
  bool _emailAlerts = true;
  bool _pushNotifications = false;
  bool _weeklyDigest = true;
  bool _marketingEmails = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('ACCOUNT SETTINGS', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tabs Bar
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTab(0, 'PROFILE', t),
                  const SizedBox(width: 8),
                  _buildTab(1, 'NOTIFICATIONS', t),
                  const SizedBox(width: 8),
                  _buildTab(2, 'BILLING', t),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Tab Content
            if (_tabIndex == 0) _buildProfileTab(t),
            if (_tabIndex == 1) _buildNotificationsTab(t),
            if (_tabIndex == 2) _buildBillingTab(t),
          ],
        ),
      ),
    );
  }

  Widget _buildTab(int index, String label, BkTokens t) {
    final isSelected = _tabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _tabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? t.primary : t.card,
          border: Border.all(color: t.border, width: t.borderWidth),
          boxShadow: isSelected
              ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))]
              : null,
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            color: isSelected ? t.primaryForeground : t.foreground,
          ),
        ),
      ),
    );
  }

  Widget _buildProfileTab(BkTokens t) {
    return BkCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('PROFILE DETAILS', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 16,
              runSpacing: 12,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  color: t.secondary,
                  child: Center(
                    child: Text(
                      'AC',
                      style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900, color: t.secondaryForeground),
                    ),
                  ),
                ),
                BkButton(
                  label: 'CHANGE AVATAR',
                  variant: BkButtonVariant.outline,
                  size: BkButtonSize.sm,
                  onPressed: () {},
                ),
              ],
            ),
            const SizedBox(height: 24),
            BkInput(label: 'FULL NAME', controller: _nameController),
            const SizedBox(height: 16),
            BkInput(label: 'EMAIL ADDRESS', controller: _emailController),
            const SizedBox(height: 16),
            BkTextarea(label: 'BIO', controller: _bioController),
            const SizedBox(height: 24),
            BkButton(
              label: 'SAVE CHANGES',
              variant: BkButtonVariant.primary,
              size: BkButtonSize.defaultSize,
              onPressed: () => BkToastManager.show(context, message: 'Profile Updated!', variant: BkToastVariant.success),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab(BkTokens t) {
    return BkCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NOTIFICATION PREFERENCES', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 20),
            _buildNotificationRow('EMAIL ALERTS', 'Receive security and account updates', _emailAlerts, (v) => setState(() => _emailAlerts = v)),
            const Divider(height: 32, thickness: 2),
            _buildNotificationRow('PUSH NOTIFICATIONS', 'Instant updates on mobile device', _pushNotifications, (v) => setState(() => _pushNotifications = v)),
            const Divider(height: 32, thickness: 2),
            _buildNotificationRow('WEEKLY DIGEST', 'Summary of your workspace activity', _weeklyDigest, (v) => setState(() => _weeklyDigest = v)),
            const Divider(height: 32, thickness: 2),
            _buildNotificationRow('MARKETING & DEALS', 'Newsletters and new feature highlights', _marketingEmails, (v) => setState(() => _marketingEmails = v)),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationRow(String title, String subtitle, bool val, ValueChanged<bool> onChanged) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: GoogleFonts.outfit(fontSize: 14, fontWeight: FontWeight.w900)),
              const SizedBox(height: 4),
              Text(subtitle, style: GoogleFonts.outfit(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
        BkSwitch(value: val, onChanged: onChanged),
      ],
    );
  }

  Widget _buildBillingTab(BkTokens t) {
    return BkCard(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('CURRENT PLAN', style: GoogleFonts.outfit(fontSize: 18, fontWeight: FontWeight.w900)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.accent,
                border: Border.all(color: t.border, width: t.borderWidth),
                boxShadow: [
                  BoxShadow(color: t.shadowColor, offset: const Offset(3, 3)),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PRO TIER', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900, color: t.accentForeground)),
                      Text('\$29 / month — Renews Nov 12', style: GoogleFonts.outfit(fontSize: 13, color: t.accentForeground)),
                    ],
                  ),
                  BkButton(
                    label: 'UPGRADE',
                    variant: BkButtonVariant.primary,
                    size: BkButtonSize.sm,
                    onPressed: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('PAYMENT METHOD', style: GoogleFonts.outfit(fontSize: 16, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Visa ending in 4242 (Expires 12/28)', style: GoogleFonts.dmMono(fontSize: 13)),
          ],
        ),
      ),
    );
  }
}
