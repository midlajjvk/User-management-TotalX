import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/bloc/auth/auth_bloc.dart';
import 'package:totalx_app/bloc/user/user_bloc.dart';
import 'package:totalx_app/screens/add_user_screen.dart';
import 'package:totalx_app/utils/app_theme.dart';
import 'package:totalx_app/widgets/user_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Users List'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<AuthBloc>().add(const AuthSignOutRequested());
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(context),
          Expanded(child: _buildUserList()),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const AddUserScreen()),
          );
          if (result == true && context.mounted) {
            context.read<UserBloc>().add(const UserFetchRequested());
          }
        },
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (value) {
          context.read<UserBloc>().add(UserSearchRequested(query: value));
        },
        decoration: InputDecoration(
          hintText: 'Search by name or phone',
          prefixIcon: const Icon(Icons.search, color: AppTheme.textSecondary),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      size: 18, color: AppTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    context
                        .read<UserBloc>()
                        .add(const UserSearchRequested(query: ''));
                  },
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildUserList() {
    return BlocConsumer<UserBloc, UserState>(
      listener: (context, state) {
        if (state is UserFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is UserLoading || state is UserSearching) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is UserSearchLoaded) {
          if (state.users.isEmpty) {
            return const Center(
              child: Text('No users found',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (_, i) => UserTile(user: state.users[i]),
          );
        }

        if (state is UserLoaded) {
          if (state.users.isEmpty) {
            return const Center(
              child: Text('No users yet. Add one!',
                  style: TextStyle(color: AppTheme.textSecondary)),
            );
          }
          return ListView.builder(
            itemCount: state.users.length,
            itemBuilder: (_, i) => UserTile(user: state.users[i]),
          );
        }

        return const SizedBox();
      },
    );
  }
}
