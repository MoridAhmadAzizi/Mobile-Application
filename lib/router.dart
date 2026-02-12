import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'features/events/ui/event_screen.dart';

RouterConfig<Object> router() => GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const EventScreen(),
        ),
      ],
    );
