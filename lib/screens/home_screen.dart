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
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'User List',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textPrimary,
                ),
              ),
            ),
          ),
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
        backgroundColor: Colors.black,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.black,
      title: const Row(
        children: [
          Icon(Icons.location_on, size: 18, color: Colors.white),
          SizedBox(width: 4),
          Text(
            'Nilambur',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          onPressed: () =>
              context.read<AuthBloc>().add(const AuthSignOutRequested()),
          icon: const Icon(Icons.logout, size: 20, color: Colors.white),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          Expanded(
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
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.dividerColor),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: const BorderSide(color: AppTheme.dividerColor),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide:
                      const BorderSide(color: AppTheme.primaryColor, width: 2),
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          BlocBuilder<UserBloc, UserState>(
            builder: (context, state) {
              final currentCategory =
                  state is UserLoaded ? state.sortCategory : SortCategory.all;
              return Stack(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius: BorderRadius.circular(30),
                      border: Border.all(color: AppTheme.dividerColor),
                    ),
                    child: IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                                top: Radius.circular(24)),
                          ),
                          builder: (_) => BlocProvider.value(
                            value: context.read<UserBloc>(),
                            child: SortBottomSheet(
                                currentCategory: currentCategory),
                          ),
                        );
                      },
                      icon: const Icon(Icons.tune,
                          size: 20, color: Colors.white),
                    ),
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
              );
            },
          ),
        ],
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
