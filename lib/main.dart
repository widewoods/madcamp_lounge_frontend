import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/auth_gate.dart';
import 'package:madcamp_lounge/theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const naverClientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');

  assert(naverClientId.isNotEmpty, 'NAVER_MAP_CLIENT_ID가 비어있습니다. --dart-define을 확인하세요.');

  await FlutterNaverMap().init(
      clientId: naverClientId,
      onAuthFailed: (ex) {
        switch (ex) {
          case NQuotaExceededException(:final message):
            print("사용량 초과 (message: $message)");
            break;
          case NUnauthorizedClientException() ||
          NClientUnspecifiedException() ||
          NAnotherAuthFailedException():
            print("인증 실패: $ex");
            break;
        }
      });

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Madcamp Lounge',
      theme: buildTheme(),
      home: const AuthGate(),
    );
  }
}

