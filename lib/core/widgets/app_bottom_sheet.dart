import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

class AppBottomSheet extends StatelessWidget {
  const AppBottomSheet({
    super.key,
    required this.title,
    required this.child,
    this.maxHeightFactor = 0.92,
  });

  final String title;
  final Widget child;
  final double maxHeightFactor;

  @override
  Widget build(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    final maxHeight = MediaQuery.sizeOf(context).height * maxHeightFactor;

    return Container(
      constraints: BoxConstraints(maxHeight: maxHeight),
      decoration: BoxDecoration(
        color: AppColors.glassSurface(brightness),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AppColors.glassBorder(brightness)),
          left: BorderSide(color: AppColors.glassBorder(brightness)),
          right: BorderSide(color: AppColors.glassBorder(brightness)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(
                    alpha: 0.35,
                  ),
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 4, 4),
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
          ),
          Flexible(child: child),
        ],
      ),
    );
  }
}

Future<T?> showAppBottomSheet<T>({
  required BuildContext context,
  required String title,
  required Widget child,
  double maxHeightFactor = 0.92,
  bool useRootNavigator = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    useRootNavigator: useRootNavigator,
    isScrollControlled: true,
    backgroundColor:AppColors.glassSurface(Theme.of(context).brightness),
    builder: (sheetContext) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: AppBottomSheet(
          title: title,
          maxHeightFactor: maxHeightFactor,
          child: child,
        ),
      );
    },
  );
}
