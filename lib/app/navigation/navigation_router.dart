import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../enums/learning_mode.dart';
import '../../models/model_lesson.dart';
import '../../pages/explore/page_explore.dart';
import '../../pages/home/page_home.dart';
import '../../pages/auth/page_auth.dart';
import '../../models/auth/model_login_request.dart';
import '../../enums/login_context.dart';
import '../../pages/lesson/page_lesson.dart';
import '../../pages/lesson/page_lesson_loading.dart';
import '../../pages/lesson/page_activity_result.dart';
import '../../pages/profile/page_profile.dart';
import '../../pages/simulation/page_simulation.dart';
import '../../pages/simulation/page_simulation_question.dart';
import '../../pages/simulation/page_simulation_result.dart';
import '../../pages/simulation/page_simulation_review.dart';
import '../../controllers/controller_simulation.dart';
import '../../models/model_simulation.dart';
import '../../models/model_activity_result.dart';
import '../../pages/social/page_social.dart';
import '../../pages/social/page_friends.dart';
import '../../pages/social/page_ranking.dart';
import '../../ui/ui_motion.dart';
import '../../services/service_registry.dart';
import '../../config/config_product.dart';
import 'navigation_app.dart';

abstract final class AppRoute {
  static const home = 'home';
  static const social = 'social';
  static const explore = 'explore';
  static const simulation = 'simulation';
  static const simulationQuestion = 'simulationQuestion';
  static const simulationResult = 'simulationResult';
  static const simulationReview = 'simulationReview';
  static const profile = 'profile';
  static const lesson = 'lesson';
  static const lessonLoading = 'lessonLoading';
  static const activityResult = 'activityResult';
  static const auth = 'auth';
  static const socialFriends = 'socialFriends';
  static const socialRanking = 'socialRanking';
}

class LessonRouteArguments {
  const LessonRouteArguments({required this.lesson, required this.mode});

  final Lesson lesson;
  final LearningMode mode;
}

class LessonLoadingRouteArguments {
  const LessonLoadingRouteArguments({required this.lesson, required this.mode});

  final Lesson lesson;
  final LearningMode mode;
}

class ActivityResultRouteArguments {
  const ActivityResultRouteArguments(this.result);
  final ActivityResult result;
}

class SimulationRouteArguments {
  const SimulationRouteArguments(this.controller);
  final SimulationController controller;
}

class SimulationResultRouteArguments extends SimulationRouteArguments {
  const SimulationResultRouteArguments({
    required SimulationController controller,
    required this.result,
    this.expired = false,
  }) : super(controller);
  final SimulationResult result;
  final bool expired;
}

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  routes: [
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          NavigationApp(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              name: AppRoute.home,
              builder: (context, state) => const PageHome(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/social',
              name: AppRoute.social,
              builder: (context, state) => const PageSocial(),
              routes: [
                GoRoute(
                  path: 'friends',
                  name: AppRoute.socialFriends,
                  redirect: (context, state) =>
                      ProductConfig.socialEnabled &&
                          ServiceRegistry.user.isAuthenticated
                      ? null
                      : '/social',
                  builder: (context, state) => const PageFriends(),
                ),
                GoRoute(
                  path: 'ranking',
                  name: AppRoute.socialRanking,
                  redirect: (context, state) =>
                      ProductConfig.socialEnabled &&
                          ServiceRegistry.user.isAuthenticated
                      ? null
                      : '/social',
                  builder: (context, state) => const PageRanking(),
                ),
              ],
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/explore',
              name: AppRoute.explore,
              builder: (context, state) => const PageExplore(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/simulation',
              name: AppRoute.simulation,
              builder: (context, state) => const PageSimulation(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              name: AppRoute.profile,
              builder: (context, state) => const PageProfile(),
            ),
          ],
        ),
      ],
    ),
    GoRoute(
      path: '/auth',
      name: AppRoute.auth,
      pageBuilder: (context, state) => _transitionPage(
        state: state,
        child: PageAuth(
          request:
              state.extra as LoginRequest? ??
              const LoginRequest(context: LoginContext.profile),
        ),
      ),
    ),
    GoRoute(
      path: '/simulation/question',
      name: AppRoute.simulationQuestion,
      redirect: (context, state) =>
          state.extra is SimulationRouteArguments ? null : '/simulation',
      pageBuilder: (context, state) => _transitionPage(
        state: state,
        child: PageSimulationQuestion(
          controller: (state.extra as SimulationRouteArguments).controller,
        ),
      ),
    ),
    GoRoute(
      path: '/simulation/result',
      name: AppRoute.simulationResult,
      redirect: (context, state) =>
          state.extra is SimulationResultRouteArguments ? null : '/simulation',
      pageBuilder: (context, state) {
        final arguments = state.extra as SimulationResultRouteArguments;
        return _transitionPage(
          state: state,
          child: PageSimulationResult(
            controller: arguments.controller,
            result: arguments.result,
            expired: arguments.expired,
          ),
        );
      },
    ),
    GoRoute(
      path: '/simulation/review',
      name: AppRoute.simulationReview,
      redirect: (context, state) =>
          state.extra is SimulationRouteArguments ? null : '/simulation',
      pageBuilder: (context, state) => _transitionPage(
        state: state,
        child: PageSimulationReview(
          controller: (state.extra as SimulationRouteArguments).controller,
        ),
      ),
    ),
    GoRoute(
      path: '/lesson/result',
      name: AppRoute.activityResult,
      redirect: (context, state) =>
          state.extra is ActivityResultRouteArguments ? null : '/home',
      pageBuilder: (context, state) => _transitionPage(
        state: state,
        child: PageActivityResult(
          result: (state.extra as ActivityResultRouteArguments).result,
        ),
      ),
    ),
    GoRoute(
      path: '/lesson/loading',
      name: AppRoute.lessonLoading,
      redirect: (context, state) =>
          state.extra is LessonLoadingRouteArguments ? null : '/home',
      pageBuilder: (context, state) {
        final arguments = state.extra as LessonLoadingRouteArguments;
        return _transitionPage(
          state: state,
          child: PageLessonLoading(
            lesson: arguments.lesson,
            mode: arguments.mode,
          ),
        );
      },
    ),
    GoRoute(
      path: '/lesson',
      name: AppRoute.lesson,
      redirect: (context, state) =>
          state.extra is LessonRouteArguments ? null : '/home',
      pageBuilder: (context, state) {
        final arguments = state.extra as LessonRouteArguments;
        return _transitionPage(
          state: state,
          child: PageLesson(lesson: arguments.lesson, mode: arguments.mode),
        );
      },
    ),
  ],
);

CustomTransitionPage<void> _transitionPage({
  required GoRouterState state,
  required Widget child,
}) => CustomTransitionPage<void>(
  key: state.pageKey,
  transitionDuration: UiMotion.screenTransitionDuration,
  reverseTransitionDuration: UiMotion.screenTransitionDuration,
  child: child,
  transitionsBuilder: (context, animation, secondaryAnimation, child) {
    final curvedAnimation = CurvedAnimation(
      parent: animation,
      curve: UiMotion.screenTransitionCurve,
      reverseCurve: UiMotion.screenTransitionCurve,
    );
    return FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: UiMotion.screenTransitionOffset,
          end: Offset.zero,
        ).animate(curvedAnimation),
        child: child,
      ),
    );
  },
);
