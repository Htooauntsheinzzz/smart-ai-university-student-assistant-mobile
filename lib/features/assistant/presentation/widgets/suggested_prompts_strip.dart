import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../../../home/presentation/widgets/home_icons.dart';
import '../../../home/presentation/widgets/home_surface.dart';
import '../demo/chat_demo_data.dart';

/// White strip (Figma node `33:72`) with the `SUGGESTED` heading and the
/// horizontally scrolling prompt chips. Tapping a chip only reports it; the
/// screen decides what happens to the composer.
class SuggestedPromptsStrip extends StatelessWidget {
  const SuggestedPromptsStrip({
    super.key,
    required this.prompts,
    required this.onPromptTap,
  });

  final List<SuggestedPrompt> prompts;
  final ValueChanged<SuggestedPrompt> onPromptTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.fieldBorder)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'SUGGESTED',
              style: AppFonts.interStyle(
                size: 10,
                weight: FontWeight.w600,
                height: 1.5,
                color: AppColors.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final (index, prompt) in prompts.indexed) ...[
                  if (index > 0) const SizedBox(width: 8),
                  _PromptChip(prompt: prompt, onTap: () => onPromptTap(prompt)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Bordered pill, 34 dp high, with the prompt's icon and text on one line.
class _PromptChip extends StatelessWidget {
  const _PromptChip({required this.prompt, required this.onTap});

  final SuggestedPrompt prompt;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: HomeSurface(
        radius: 999,
        onTap: onTap,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        child: ConstrainedBox(
          // 34 minimum height including the 1 dp border and 7 dp padding on
          // each side.
          constraints: const BoxConstraints(minHeight: 34 - 2 - 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              HomeIcon(prompt.icon, size: 13),
              const SizedBox(width: 6),
              Text(
                prompt.text,
                style: AppFonts.interStyle(
                  size: 10,
                  height: 1.5,
                  color: AppColors.textPrompt,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
