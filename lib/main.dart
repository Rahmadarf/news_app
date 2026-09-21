import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:news_app/app/app.dart';
import 'package:news_app/app/bootstrap.dart';

Future<void> main() async {
  final BootstrapResult result = await bootstrap();

  runApp(switch (result) {
    BootstrapSuccess(:final List<Override> overrides) => ProviderScope(
      overrides: overrides,
      child: const NewsApp(),
    ),
    BootstrapFailure(:final error) => ConfigurationErrorApp(error: error),
  });
}
