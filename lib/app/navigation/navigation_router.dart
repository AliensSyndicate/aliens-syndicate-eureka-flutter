import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../enums/learning_mode.dart';
import '../../models/content/model_content_manifest.dart';
import '../../models/model_lesson.dart';
import '../../pages/auth/page_auth.dart';
import '../../pages/explore/page_explore.dart';
import '../../pages/home/page_home.dart';
import '../../pages/lesson/page_lesson.dart';
import '../../pages/lesson/page_lesson_loading.dart';
import '../../pages/profile/page_profile.dart';
import '../../pages/simulation/page_simulation.dart';
import '../../pages/social/page_social.dart';
import '../../pages/subject/page_subject_lessons.dart';
import '../../ui/ui_motion.dart';
import 'navigation_app.dart';

abstract final class AppRoute {
  static const home = 'home';
  static const social = 'social';
  static const explore = 'explore';
  static const simulation = 'simulation';
  static const profile = 'profile';
  static const auth = 'auth';
  static const subject = 'subject';
  static const lesson = 'lesson';
  static const lessonLoading = 'lessonLoading';
}

class SubjectRouteArguments {
  const SubjectRouteArguments({
    required this.subject,
    required this.schoolYear,
  });

  final SubjectContentManifest subject;
  final int schoolYear;
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
      pageBuilder: (context, state) =>
          _transitionPage(state: state, child: const PageAuth()),
    ),
    GoRoute(
      path: '/subject',
      name: AppRoute.subject,
      redirect: (context, state) =>
          state.extra is SubjectRouteArguments ? null : '/home',
      pageBuilder: (context, state) {
        final arguments = state.extra as SubjectRouteArguments;
        return _transitionPage(
          state: state,
          child: PageSubjectLessons(
            subject: arguments.subject,
            schoolYear: arguments.schoolYear,
          ),
        );
      },
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
