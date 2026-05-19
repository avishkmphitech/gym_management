import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'router/app_router.dart';
import 'services/auth_service.dart';
import 'widgets/dev_role_switcher.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: FitCoreMemberApp()));
}

class FitCoreMemberApp extends ConsumerStatefulWidget {
  const FitCoreMemberApp({super.key});

  @override 
  ConsumerState<FitCoreMemberApp> createState() => _FitCoreMemberAppState();
}

class _FitCoreMemberAppState extends ConsumerState<FitCoreMemberApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(authServiceProvider.notifier).loadFromStorage();
    });
  }

  @override
  Widget build(BuildContext context) {
    final router = ref.watch(memberRouterProvider);
    return MaterialApp.router(
      title: 'FitCore Member',
      debugShowCheckedModeBanner: false,
      theme: buildFitCoreTheme(),
      routerConfig: router,
      builder: (context, child) {
        if (!kDebugMode || child == null) {
          return child ?? const SizedBox.shrink();
        }
        return Stack(
          clipBehavior: Clip.none,
          children: [
            child,
            const Positioned(
              left: 12,
              bottom: 12,
              child: DevRoleSwitcher(),
            ),
          ],
        );
      },
    );
  }
}
