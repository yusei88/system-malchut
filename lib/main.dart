import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:package_info_plus/package_info_plus.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  runApp(MainApp(packageInfo: packageInfo,));
}

class MainApp extends StatelessWidget {
  final PackageInfo packageInfo;
  const MainApp({super.key, required this.packageInfo});

  @override
  Widget build(BuildContext context) {
    String appName = packageInfo.appName;
    String packageName = packageInfo.packageName;
    String version = packageInfo.version;
    String buildNumber = packageInfo.buildNumber;
    const flavor = String.fromEnvironment('flavor');
    return MaterialApp(
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              children: [
                const Text('Hello World!'),
                const Text('flavor: $flavor'),
                Text('appName: $appName'),
                Text('packageName: $packageName'),
                Text('version: $version'),
                Text('buildNumber: $buildNumber'),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
