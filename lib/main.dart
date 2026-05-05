import 'package:ehbien_lotto_admin/app/app_bootstrap.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppBootstrap.initialize();
}
