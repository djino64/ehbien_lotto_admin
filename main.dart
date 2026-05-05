// lib/main.dart

import 'package:flutter/material.dart';
import 'package:ehbien_lotto_admin/app/app_bootstrap.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
}