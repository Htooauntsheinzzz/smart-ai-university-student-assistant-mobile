import 'package:flutter/material.dart';

import '../../../../app/theme/app_theme.dart';
import '../controllers/auth_controller.dart';

/// White login card: heading, email and password fields, "Keep me signed in"
/// and the Sign In button.
///
/// Only local input checks live here; actual authentication goes
/// through [AuthController] (DEC-010). The design is the same as the
/// Figma frame (DEC-005); progress is shown inside the button at the
/// same size, and error messages from the backend appear just above it.
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.controller});

  final AuthController controller;

  static const String resetUnavailableMessage =
      'Password reset is not available yet.';

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  static final RegExp _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordFocus = FocusNode();
  // Tapping the visibility toggle must not take focus from the field.
  final _toggleFocus = FocusNode(skipTraversal: true, canRequestFocus: false);

  bool _obscurePassword = true;
  bool _keepSignedIn = false;
  AutovalidateMode _autovalidateMode = AutovalidateMode.onUnfocus;

  bool get _canSubmit =>
      !widget.controller.isSubmitting &&
      _validateEmail(_emailController.text) == null &&
      _validatePassword(_passwordController.text) == null;

  @override
  void initState() {
    super.initState();
    _emailController.addListener(_onInputChanged);
    _passwordController.addListener(_onInputChanged);
    widget.controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(LoginForm oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller.removeListener(_onControllerChanged);
      widget.controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onControllerChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _passwordFocus.dispose();
    _toggleFocus.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    if (!mounted) return;
    setState(() {});
  }

  void _onInputChanged() {
    // Clear a previous backend error once the user starts typing so a
    // stale "Invalid email or password." does not linger over a fresh
    // attempt.
    if (widget.controller.errorMessage != null) {
      widget.controller.clearError();
    } else {
      setState(() {});
    }
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Enter your student email.';
    if (!_emailPattern.hasMatch(email)) return 'Enter a valid email address.';
    return null;
  }

  String? _validatePassword(String? value) {
    // The password is checked as typed: no trimming or other changes.
    if (value == null || value.isEmpty) return 'Enter your password.';
    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _autovalidateMode = AutovalidateMode.always);
    if (!(_formKey.currentState?.validate() ?? false)) return;
    if (widget.controller.isSubmitting) return;
    await widget.controller.login(
      universityEmail: _emailController.text,
      password: _passwordController.text,
      keepSignedIn: _keepSignedIn,
    );
    // If authentication succeeded, AuthGate has already swapped this
    // widget out, so there is nothing left to do here.
  }

  @override
  Widget build(BuildContext context) {
    final labelStyle = AppFonts.interStyle(
      size: 11,
      weight: FontWeight.w600,
      color: AppColors.textPrimary,
    );
    final errorMessage = widget.controller.errorMessage;
    final submitting = widget.controller.isSubmitting;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.fieldBorder),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidateMode,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Welcome back',
              style: AppFonts.poppinsBold(
                size: 18,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Enter your RSU credentials to continue.',
              style: AppFonts.interStyle(
                size: 11,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            Text('Student Email', style: labelStyle),
            const SizedBox(height: 6),
            _LoginTextField(
              controller: _emailController,
              hintText: 'e.g. 6512345678@rsu.ac.th',
              icon: Icons.mail_outline,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              enabled: !submitting,
              validator: _validateEmail,
              onFieldSubmitted: (_) => _passwordFocus.requestFocus(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(child: Text('Password', style: labelStyle)),
                const SizedBox(width: AppSpacing.sm),
                Flexible(
                  child: _ForgotPasswordLink(
                    onTap: () =>
                        _showMessage(LoginForm.resetUnavailableMessage),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            _LoginTextField(
              controller: _passwordController,
              focusNode: _passwordFocus,
              hintText: 'Enter your password',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              keyboardType: TextInputType.visiblePassword,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              enabled: !submitting,
              validator: _validatePassword,
              onFieldSubmitted: (_) {
                if (_canSubmit) _submit();
              },
              suffix: IconButton(
                onPressed: submitting
                    ? null
                    : () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                tooltip: _obscurePassword ? 'Show password' : 'Hide password',
                // The frame shows the crossed-out eye while the password is
                // hidden, so the icon reflects the current state.
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 18,
                ),
                color: AppColors.placeholder,
                focusNode: _toggleFocus,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            _KeepSignedIn(
              value: _keepSignedIn,
              onChanged: submitting
                  ? null
                  : (value) => setState(() => _keepSignedIn = value),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              _ErrorBanner(message: errorMessage),
            ],
            const SizedBox(height: AppSpacing.md),
            _SignInButton(
              submitting: submitting,
              onPressed: _canSubmit ? _submit : null,
            ),
          ],
        ),
      ),
    );
  }
}

/// Rounded, filled text field with a leading icon, as in Figma.
class _LoginTextField extends StatelessWidget {
  const _LoginTextField({
    required this.controller,
    required this.hintText,
    required this.icon,
    required this.validator,
    this.focusNode,
    this.keyboardType,
    this.textInputAction,
    this.autofillHints,
    this.obscureText = false,
    this.onFieldSubmitted,
    this.suffix,
    this.enabled = true,
  });

  final TextEditingController controller;
  final FocusNode? focusNode;
  final String hintText;
  final IconData icon;
  final FormFieldValidator<String> validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Iterable<String>? autofillHints;
  final bool obscureText;
  final ValueChanged<String>? onFieldSubmitted;
  final Widget? suffix;
  final bool enabled;

  static OutlineInputBorder _border(Color color, [double width = 1]) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: color, width: width),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      enabled: enabled,
      validator: validator,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      obscureText: obscureText,
      autocorrect: false,
      enableSuggestions:
          !obscureText && keyboardType != TextInputType.emailAddress,
      textCapitalization: TextCapitalization.none,
      onFieldSubmitted: onFieldSubmitted,
      cursorColor: AppColors.textPrimary,
      style: AppFonts.interStyle(size: 16, color: AppColors.textPrimary),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: AppFonts.interStyle(size: 16, color: AppColors.placeholder),
        errorStyle: AppFonts.interStyle(size: 11, color: AppColors.error),
        errorMaxLines: 3,
        filled: true,
        fillColor: AppColors.fieldBackground,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: 14,
        ),
        prefixIcon: Padding(
          padding: const EdgeInsets.only(left: AppSpacing.md, right: 12),
          child: Icon(icon, size: 18, color: AppColors.placeholder),
        ),
        prefixIconConstraints: const BoxConstraints(minHeight: 52),
        suffixIcon: suffix == null
            ? null
            : Padding(padding: const EdgeInsets.only(right: 4), child: suffix),
        suffixIconConstraints: const BoxConstraints(minHeight: 52),
        enabledBorder: _border(AppColors.fieldBorder),
        focusedBorder: _border(AppColors.textPrimary, 1.5),
        errorBorder: _border(AppColors.error),
        focusedErrorBorder: _border(AppColors.error, 1.5),
      ),
    );
  }
}

/// "Forgot Password?" text action with a comfortable touch area.
class _ForgotPasswordLink extends StatelessWidget {
  const _ForgotPasswordLink({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs,
            vertical: AppSpacing.sm,
          ),
          child: Text(
            'Forgot Password?',
            textAlign: TextAlign.end,
            style: AppFonts.interStyle(
              size: 11,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}

/// Checkbox plus label; tapping either toggles the value.
class _KeepSignedIn extends StatelessWidget {
  const _KeepSignedIn({required this.value, required this.onChanged});

  final bool value;
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) {
    final disabled = onChanged == null;
    return MergeSemantics(
      child: InkWell(
        onTap: disabled ? null : () => onChanged!(!value),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
          child: Row(
            children: [
              SizedBox.square(
                dimension: 20,
                child: Checkbox(
                  value: value,
                  onChanged: disabled
                      ? null
                      : (checked) => onChanged!(checked ?? false),
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                  activeColor: AppColors.textPrimary,
                  checkColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  side: const BorderSide(
                    color: AppColors.checkboxBorder,
                    width: 2,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Keep me signed in',
                  style: AppFonts.interStyle(
                    size: 12,
                    weight: FontWeight.w500,
                    color: AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Inline error banner shown above the Sign In button.
class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      liveRegion: true,
      container: true,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.error.withValues(alpha: 0.35)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.error_outline, size: 16, color: AppColors.error),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: AppFonts.interStyle(
                  size: 12,
                  weight: FontWeight.w500,
                  color: AppColors.error,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Full-width Sign In button with a trailing arrow. Shows a spinner
/// inside the same button area while a request is in flight (spec
/// section 8).
class _SignInButton extends StatelessWidget {
  const _SignInButton({required this.onPressed, required this.submitting});

  final VoidCallback? onPressed;
  final bool submitting;

  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: Colors.white,
        disabledBackgroundColor: AppColors.buttonDisabled,
        disabledForegroundColor: AppColors.onButtonDisabled,
        textStyle: AppFonts.interStyle(size: 13),
      ),
      child: submitting
          ? const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
          : const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Flexible(child: Text('Sign In', textAlign: TextAlign.center)),
                SizedBox(width: 10),
                Icon(Icons.arrow_forward, size: 16),
              ],
            ),
    );
  }
}
