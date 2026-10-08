import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_motion.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';
import '../../../data/mock_data.dart';

class TeamScreen extends StatelessWidget {
  const TeamScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('MEET THE CREW',
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THE MINDS BEHIND BOLDKIT',
              style: GoogleFonts.outfit(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5),
            ),
            const SizedBox(height: 8),
            Text(
              'A decentralized group of designers and systems architects obsessed with neo-brutalism.',
              style: GoogleFonts.outfit(fontSize: 15, color: t.mutedForeground),
            ),
            const SizedBox(height: 28),
            LayoutBuilder(
              builder: (context, constraints) {
                final crossAxisCount = constraints.maxWidth > 900
                    ? 3
                    : (constraints.maxWidth > 550 ? 2 : 1);
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    mainAxisExtent: crossAxisCount == 3
                        ? 230
                        : (crossAxisCount == 2 ? 220 : 200),
                  ),
                  itemCount: mockTeam.length,
                  itemBuilder: (context, index) {
                    final member = mockTeam[index];
                    return BkCard(
                      interactive: true,
                      onTap: () => _showMemberSheet(context, member, t),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            color: Color(member.avatarColor),
                            child: Center(
                              child: Text(
                                member.avatarInitials,
                                style: GoogleFonts.outfit(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w900,
                                  color: t.foreground,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            member.name.toUpperCase(),
                            style: GoogleFonts.outfit(
                                fontSize: 15, fontWeight: FontWeight.w900),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            member.role,
                            style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: t.primary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            member.bio,
                            style: GoogleFonts.outfit(
                                fontSize: 11,
                                color: t.mutedForeground,
                                height: 1.3),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  void _showMemberSheet(
      BuildContext context, MockTeamMember member, BkTokens t) {
    BkMotion.hapticClick();
    showBkBottomSheet(
      context: context,
      title: member.name.toUpperCase(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
                color: Color(member.avatarColor),
                child: Center(
                  child: Text(
                    member.avatarInitials,
                    style: GoogleFonts.outfit(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: t.foreground,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      member.name.toUpperCase(),
                      style: GoogleFonts.outfit(
                          fontSize: 18, fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    BkBadge(
                        label: member.role.toUpperCase(),
                        variant: BkBadgeVariant.secondary),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            member.bio,
            style: GoogleFonts.outfit(
                fontSize: 14, color: t.foreground, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              BkBadge(label: 'GITHUB', variant: BkBadgeVariant.outline),
              BkBadge(label: 'TWITTER / X', variant: BkBadgeVariant.outline),
              BkBadge(label: 'LINKEDIN', variant: BkBadgeVariant.outline),
            ],
          ),
          const SizedBox(height: 24),
          BkButton(
            label: 'CLOSE',
            variant: BkButtonVariant.primary,
            size: BkButtonSize.defaultSize,
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}
