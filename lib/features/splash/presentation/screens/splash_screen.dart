import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_boilerplate/config/flavor_config.dart';
import 'package:riverpod_boilerplate/core/constants/route_constants.dart';
import 'package:riverpod_boilerplate/core/theme/app_colors.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..forward();

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        context.go(RouteConstants.home);
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark ? AppColors.gradientDark : AppColors.gradientLight;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: gradient,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                const Spacer(),
                Icon(
                  Icons.account_balance_wallet_outlined,
                  size: 56,
                  color: scheme.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  FlavorConfig.config.appName,
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 14),
                Text(
                  'app.loading'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                AnimatedBuilder(
                  animation: _controller,
                  builder: (context, child) {
                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 6,
                            value: _controller.value,
                            backgroundColor:
                                scheme.surfaceContainerHighest.withValues(
                              alpha: 0.5,
                            ),
                            valueColor: AlwaysStoppedAnimation(scheme.primary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${(_controller.value * 100).toInt()}%',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
