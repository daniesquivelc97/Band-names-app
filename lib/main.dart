import 'package:band_names_app/pages/home.dart';
import 'package:band_names_app/pages/status.dart';
import 'package:band_names_app/services/socket_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SocketService(),
        )
      ],
      child: MaterialApp(
        title: 'Material App',
        initialRoute: 'home',
        debugShowCheckedModeBanner: false,
        routes: {
          'home': (_) => HomePage(),
          'status': (_) => StatusPage(),
        },
      ),
    );
  }
}
