import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/bloc/auth/auth_bloc.dart';
import 'package:totalx_app/utils/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TotalX'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Welcome to TotalX!',
          style: TextStyle(
            fontSize: 18,
            color: AppTheme.textSecondary,
          ),
        ),
      ),
    );
  }
}
