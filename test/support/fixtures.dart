import 'dart:io';

import 'package:news_app/features/news/data/datasources/mock_news_data_source.dart';

/// Reads the committed fixtures straight from disk.
///
/// Lets plain unit tests use the same files the app bundles as assets, without
/// initializing a Flutter asset bundle.
Future<String> loadFixtureFromDisk(String assetKey) =>
    File(assetKey).readAsString();

/// Mock source wired to the on-disk fixtures.
MockNewsDataSource fixtureBackedMockSource() =>
    MockNewsDataSource(loadFixture: loadFixtureFromDisk);
