import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../demo/home_demo_data.dart';
import 'home_icons.dart';
import 'home_surface.dart';

/// Dark "Smart AI" card (Figma node `3:334`) with suggested questions and the
/// Ask AI Assistant button. No prompt is sent from here.
class AiAssistantCard extends StatelessWidget {
  const AiAssistantCard({
    super.key,
    required this.suggestions,
    required this.onSuggestionTap,
    required this.onAskTap,
  });

  final List<HomeSuggestion> suggestions;
  final ValueChanged<HomeSuggestion> onSuggestionTap;
  final VoidCallback onAskTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      color: AppColors.background,
      borderColor: AppColors.avatar,
      shadows: AppShadows.darkCard,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _Heading(),
          const SizedBox(height: 12),
          for (final (index, suggestion) in suggestions.indexed) ...[
            if (index > 0) const SizedBox(height: 8),
            _SuggestionButton(
              suggestion: suggestion,
              onTap: () => onSuggestionTap(suggestion),
            ),
          ],
          const SizedBox(height: 12),
          _AskButton(onTap: onAskTap),
        ],
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.accentBlue.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.accentBlue.withValues(alpha: 0.3),
            ),
          ),
          child: const HomeIcon(HomeIcons.aiRobot, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.91),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      'SMART AI',
                      style: AppFonts.interStyle(
                        size: 9,
                        weight: FontWeight.w900,
                        height: 1.5,
                        letterSpacing: 0.9,
                        color: AppColors.accentBlue,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                'How can I help you today?',
                style: AppFonts.poppinsBold(
                  size: 14,
                  height: 1.5,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SuggestionButton extends StatelessWidget {
  const _SuggestionButton({required this.suggestion, required this.onTap});

  final HomeSuggestion suggestion;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      color: const Color(0x1AFFFFFF),
      borderColor: const Color(0x26FFFFFF),
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: ConstrainedBox(
        // 46 minimum height including the 1 dp border on each side.
        constraints: const BoxConstraints(minHeight: 46 - 16),
        child: Row(
          children: [
            HomeIcon(suggestion.icon, size: 16),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                suggestion.label,
                style: AppFonts.interStyle(
                  size: 11,
                  height: 1.5,
                  color: const Color(0xCCFFFFFF),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AskButton extends StatelessWidget {
  const _AskButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return HomeSurface(
      borderColor: null,
      shadows: AppShadows.raised,
      onTap: onTap,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 50 - 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const HomeIcon(HomeIcons.askAiChat, size: 16),
            const SizedBox(width: 10),
            Flexible(
              child: Text(
                'Ask AI Assistant',
                textAlign: TextAlign.center,
                style: AppFonts.interStyle(
                  size: 13,
                  height: 1.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
