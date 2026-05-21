import 'package:go_router/go_router.dart';
import 'package:riverpod_boilerplate/core/constants/route_constants.dart';
import 'package:riverpod_boilerplate/features/splash/presentation/screens/splash_screen.dart';

import '../../features/home/presentation/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: RouteConstants.splash,
  routes: [
    GoRoute(
      path: RouteConstants.splash,
      builder: (context, state) => const SplashScreen(),
    ),
    GoRoute(
      path: RouteConstants.home,
      builder: (context, state) => const HomeScreen(),
    ),
  ],
  redirect: (context, state) {
    final path = state.uri.path;
    if (path == RouteConstants.finance ||
        path == RouteConstants.financeAdd ||
        path == RouteConstants.settings) {
      return RouteConstants.home;
    }
    return null;
  },
);
