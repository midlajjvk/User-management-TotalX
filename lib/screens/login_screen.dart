import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/bloc/auth/auth_bloc.dart';
import 'package:totalx_app/utils/app_theme.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Login or create an Account',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Spacer(),
              const Text(
                'Welcome',
                style: TextStyle(
                  fontSize: 29,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryColor,
                ),
              ),
              const Text(
                'TOTAL-X',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryColor,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 20),
              Image.asset(
                'assets/images/loginimage.png',
                width: double.infinity,
                fit: BoxFit.contain,
              ),
              const Spacer(),
              BlocBuilder<AuthBloc, AuthState>(
                builder: (context, state) {
                  return _GoogleSignInButton(
                    isLoading: state is AuthLoading,
                    onPressed: () {
                      context
                          .read<AuthBloc>()
                          .add(const AuthGoogleSignInRequested());
                    },
                  );
                },
              ),
              const SizedBox(height: 16),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textPrimary,
                  ),
                  children: const [
                    TextSpan(text: 'By Continuing, I agree to TotalX\'s '),
                    TextSpan(
                      text: 'Terms and condition',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                    TextSpan(text: ' & '),
                    TextSpan(
                      text: 'privacy policy',
                      style: TextStyle(color: AppTheme.primaryColor),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleSignInButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const _GoogleSignInButton({
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: isLoading ? null : onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Color(0xFFDBDCE0), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          backgroundColor: Colors.white,
        ),
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: AppTheme.primaryColor,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.asset(
                    'assets/images/googleicon.png',
                    width: 22,
                    height: 22,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Continue With Google',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
