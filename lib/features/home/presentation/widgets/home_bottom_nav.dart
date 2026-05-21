import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:riverpod_boilerplate/core/theme/app_colors.dart';
import 'package:riverpod_boilerplate/core/widgets/glass_background.dart';
import 'package:riverpod_boilerplate/features/home/presentation/cubit/home_nav_cubit.dart';
import 'package:riverpod_boilerplate/shared/di/app_dependencies.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  static const tabs = [
    _TabItem('app.home', Icons.home_outlined),
    _TabItem('app.menu', Icons.restaurant_menu_outlined),
    _TabItem('app.orders', Icons.receipt_long_outlined),
    _TabItem('app.rewards', Icons.card_giftcard_outlined),
    _TabItem('app.profile', Icons.person_outline),
  ];

  @override
  Widget build(BuildContext context) {
    final navState = context.watch<HomeNavCubit>().state;
    final selectedIndex = navState.currentIndex;
    final deps = context.read<AppDependencies>();
    final haptic = deps.haptic;
    final motion = deps.microInteraction;

    return GlassBackground(
      color: AppColors.surface.withValues(alpha: 0.25),
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      border: .all(color: Colors.white.withValues(alpha: 0.12)),
      child: Padding(
        padding: .fromLTRB(
          6,
          10,
          6,
          MediaQuery.of(context).padding.bottom + 6,
        ),
        child: Row(
          children: List.generate(tabs.length, (index) {
            final selected = selectedIndex == index;
            final item = tabs[index];

            return Expanded(
              child: GestureDetector(
                onTap: () async {
                  if (selectedIndex == index) return;
                  final nav = context.read<HomeNavCubit>();
                  await haptic.selectionClick();
                  nav.setIndex(index);
                },
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: motion.tabStaggerDuration(index),
                  curve: Curves.easeOutBack,
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      /// Icon with lift & scale only
                      AnimatedScale(
                        duration: motion.tabStaggerDuration(index),
                        curve: Curves.easeOutBack,
                        scale: selected ? 1.2 : 1.0,
                        child: AnimatedSlide(
                          duration: motion.tabStaggerDuration(index),
                          offset:
                          selected ? const Offset(0, -0.15) : Offset.zero,
                          child: Icon(
                            item.icon,
                            size: 22,
                            color: selected
                                ? AppColors.textPrimaryDark
                                : Colors.white70,
                          ),
                        ),
                      ),

                      const SizedBox(height: 2),

                      /// Label
                      AnimatedDefaultTextStyle(
                        duration: motion.tabStaggerDuration(index),
                        curve: Curves.easeOut,
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(
                          fontSize: selected ? 12 : 11,
                          fontWeight: selected
                              ? FontWeight.w600
                              : FontWeight.w500,
                          color: selected
                              ? AppColors.textPrimaryDark
                              : Colors.white70,
                        ) ??
                            const TextStyle(),
                        child: Text(item.labelKey.tr()),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _TabItem {
  const _TabItem(this.labelKey, this.icon);

  final String labelKey;
  final IconData icon;
}
