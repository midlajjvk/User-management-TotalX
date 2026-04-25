import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:totalx_app/bloc/user/user_bloc.dart';
import 'package:totalx_app/utils/app_theme.dart';

class SortBottomSheet extends StatefulWidget {
  final SortCategory currentCategory;

  const SortBottomSheet({super.key, required this.currentCategory});

  @override
  State<SortBottomSheet> createState() => _SortBottomSheetState();
}

class _SortBottomSheetState extends State<SortBottomSheet> {
  late SortCategory _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.currentCategory;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Sort by Age',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          RadioListTile<SortCategory>(
            title: const Text('All'),
            value: SortCategory.all,
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val!),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<SortCategory>(
            title: const Text('Younger (Age ≤ 60)'),
            value: SortCategory.younger,
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val!),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<SortCategory>(
            title: const Text('Older (Age > 60)'),
            value: SortCategory.older,
            groupValue: _selected,
            onChanged: (val) => setState(() => _selected = val!),
            activeColor: AppTheme.primaryColor,
            contentPadding: EdgeInsets.zero,
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () {
                context
                    .read<UserBloc>()
                    .add(UserSortChanged(category: _selected));
                Navigator.pop(context);
              },
              child: const Text('Apply'),
            ),
          ),
        ],
      ),
    );
  }
}
