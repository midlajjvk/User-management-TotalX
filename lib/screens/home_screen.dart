import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/bloc/auth/auth_bloc.dart';
import 'package:totalx_app/bloc/user/user_bloc.dart';
import 'package:totalx_app/screens/add_user_screen.dart';
import 'package:totalx_app/utils/app_theme.dart';
import 'package:totalx_app/widgets/sort_bottom_sheet.dart';
import 'package:totalx_app/widgets/user_tile.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    if (currentScroll >= maxScroll * 0.9) {
      context.read<UserBloc>().add(const UserFetchMoreRequested());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: _buildAppBar(context),
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

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      title: const Text('Users List'),
      actions: [
        BlocBuilder<UserBloc, UserState>(
          builder: (context, state) {
            final currentCategory =
                state is UserLoaded ? state.sortCategory : SortCategory.all;
            return IconButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  builder: (_) => BlocProvider.value(
                    value: context.read<UserBloc>(),
                    child: SortBottomSheet(currentCategory: currentCategory),
                  ),
                );
              },
              icon: Stack(
                children: [
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: const Icon(Icons.tune,
                        size: 20, color: AppTheme.textPrimary),
                  ),
                  if (currentCategory != SortCategory.all)
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 10,
                        height: 10,
                        decoration: const BoxDecoration(
                          color: AppTheme.primaryColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
        IconButton(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthSignOutRequested()),
          icon: const Icon(Icons.logout, size: 20),
        ),
        const SizedBox(width: 4),
      ],
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
          prefixIcon:
              const Icon(Icons.search, color: AppTheme.textSecondary),
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
          return ListView.builder(
            itemCount: 8,
            itemBuilder: (_, __) => const UserTileShimmer(),
          );
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
            controller: _scrollController,
            itemCount: state.hasReachedMax
                ? state.users.length
                : state.users.length + 1,
            itemBuilder: (_, index) {
              if (index >= state.users.length) {
                return const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                );
              }
              return UserTile(user: state.users[index]);
            },
          );
        }

        return const SizedBox();
      },
    );
  }
}
