import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:madcamp_lounge/auth_gate.dart';
import 'package:madcamp_lounge/theme.dart';

const naverSearchClientID = String.fromEnvironment('NAVER_SEARCH_CLIENT_ID');
const naverSearchClientSecret = String.fromEnvironment('NAVER_SEARCH_CLIENT_SECRET');
const ncpClientID = String.fromEnvironment("X-NCP-APIGW-API-KEY-ID");
const ncpClientKey = String.fromEnvironment("X-NCP-APIGW-API-KEY");

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const naverClientId = String.fromEnvironment('NAVER_MAP_CLIENT_ID');

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

