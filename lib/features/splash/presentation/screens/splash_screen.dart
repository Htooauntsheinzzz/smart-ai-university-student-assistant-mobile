import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';

/// Initial loading / splash screen shown while the top-level
/// [AuthGate] waits for session restoration (DEC-010).
///
/// Layout (top to bottom, centred): university logo drawn directly on
/// the background (transparent PNG, no card), "SMART • AI" label, app
/// title, subtitle flanked by rule lines, "RANGSIT UNIVERSITY", a
/// progress bar, three dots and a caption pinned to the bottom.
///
/// The screen no longer owns navigation. The parent swaps it out once
/// authentication state is known. When [errorMessage] is set and
/// [onRetry] is supplied the caption is replaced with the message and a
/// Try Again button, used when a temporary network failure stops
/// session restoration (spec section 11).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    this.duration = defaultDuration,
    this.errorMessage,
    this.onRetry,
  });

  static const String logoAsset = 'assets/images/rangsitlogo.png';

  static const Duration defaultDuration = Duration(milliseconds: 2500);

  /// Time for the progress bar to fill once; after that it loops to
  /// keep the "something is happening" cue while restoration finishes.
  final Duration duration;

  /// Short, user-facing error message to show instead of the normal
  /// loading caption. Must be paired with [onRetry].
  final String? errorMessage;

  /// Called when the user taps Try Again on the error state.
  final VoidCallback? onRetry;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progress;

  @override
  void initState() {
    super.initState();
    _progress = AnimationController(vsync: this, duration: widget.duration);
    if (!_hasError) _progress.repeat();
  }

  @override
  void didUpdateWidget(SplashScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Stop the running animation once the parent swaps us into the
    // error state (the loader is replaced by the error panel), so tests
    // and tools don't hang on an endlessly-pending frame.
    if (_hasError && _progress.isAnimating) {
      _progress.stop();
    } else if (!_hasError && !_progress.isAnimating) {
      _progress.repeat();
    }
  }

  @override
  void dispose() {
    _progress.dispose();
    super.dispose();
  }

  bool get _hasError => widget.errorMessage != null && widget.onRetry != null;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Android can lay out a first frame before the window has a size;
            // never hand a negative width down to the text constraints.
            final contentWidth = math.max(
              0.0,
              constraints.maxWidth - AppSpacing.xl * 2,
            );
            return CustomScrollView(
              slivers: [
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xl,
                      vertical: AppSpacing.lg,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 3),
                        const _Logo(),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          'SMART • AI',
                          textAlign: TextAlign.center,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.skyBlue,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 4,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'University Student Assistant',
                          textAlign: TextAlign.center,
                          style: textTheme.headlineSmall?.copyWith(
                            color: AppColors.onBackground,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _RuledText(
                          'Your Smart Campus Companion',
                          maxTextWidth: contentWidth * 0.8,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.onBackgroundMuted,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text(
                          'RANGSIT UNIVERSITY',
                          textAlign: TextAlign.center,
                          style: textTheme.labelMedium?.copyWith(
                            color: AppColors.onBackgroundMuted,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 2,
                          ),
                        ),
                        const Spacer(flex: 2),
                        if (!_hasError) ...[
                          _ProgressBar(progress: _progress),
                          const SizedBox(height: AppSpacing.md),
                          const _Dots(),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'Loading your campus experience...',
                            textAlign: TextAlign.center,
                            style: textTheme.bodySmall?.copyWith(
                              color: AppColors.onBackgroundMuted,
                            ),
                          ),
                        ] else
                          _ErrorPanel(
                            message: widget.errorMessage!,
                            onRetry: widget.onRetry!,
                          ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// University logo drawn directly on the background with no card behind it.
///
/// The asset is the Figma export (1480×1660, white wordmark on a transparent
/// background, artwork filling the canvas), so it is shown as-is at a fixed
/// width; the height follows from the image's own aspect ratio.
class _Logo extends StatelessWidget {
  const _Logo();

  static const double _width = 180;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      image: true,
      label: 'Rangsit University logo',
      child: Image.asset(
        SplashScreen.logoAsset,
        width: _width,
        fit: BoxFit.contain,
        excludeFromSemantics: true,
      ),
    );
  }
}

/// Text with a thin horizontal rule on each side.
class _RuledText extends StatelessWidget {
  const _RuledText(this.text, {required this.maxTextWidth, this.style});

  final String text;

  /// Widest the text may grow before wrapping, leaving room for the rules.
  final double maxTextWidth;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    const rule = Expanded(child: Divider(color: AppColors.rule, thickness: 1));
    // The text keeps its natural width (so it stays on one line when it
    // fits) and the rules fill whatever is left; it only wraps once it would
    // exceed most of the available width, e.g. with large text scaling.
    return Row(
      children: [
        rule,
        ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxTextWidth),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Text(text, textAlign: TextAlign.center, style: style),
          ),
        ),
        rule,
      ],
    );
  }
}

/// Progress bar driven by the splash timer. Loops indefinitely while
/// session restoration is in flight.
class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.progress});

  final Animation<double> progress;

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 240),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999),
        child: AnimatedBuilder(
          animation: progress,
          builder: (context, _) => LinearProgressIndicator(
            value: progress.value,
            minHeight: 6,
            semanticsLabel: 'Loading',
          ),
        ),
      ),
    );
  }
}

/// Three static dots beneath the progress bar, as shown in the design.
class _Dots extends StatelessWidget {
  const _Dots();

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(3, (i) {
          return Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i == 0 ? AppColors.skyBlue : AppColors.rule,
            ),
          );
        }),
      ),
    );
  }
}

/// Error panel shown in place of the progress bar when session
/// restoration fails on a temporary network issue (spec section 11).
class _ErrorPanel extends StatelessWidget {
  const _ErrorPanel({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: textTheme.bodyMedium?.copyWith(
            color: AppColors.onBackground,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Center(
          child: FilledButton(
            onPressed: onRetry,
            style: FilledButton.styleFrom(
              minimumSize: const Size(160, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text('Try Again'),
          ),
        ),
      ],
    );
  }
}
