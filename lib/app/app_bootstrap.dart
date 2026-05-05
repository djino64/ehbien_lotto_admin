// lib/app/app_bootstrap.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:ehbien_lotto_admin/firebase_options.dart';
import 'package:ehbien_lotto_admin/app/app.dart';

class AppBootstrap {
  AppBootstrap._();

  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    runApp(
      const ProviderScope(
        child: EhbienAdminApp(),
      ),
    );
  }
}