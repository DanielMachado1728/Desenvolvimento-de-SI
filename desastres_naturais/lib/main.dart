import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'pages/add_contact_page.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ark App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      //home: const HomePage(),
      home: const LoginPage(),

      routes: {
        '/add_contact': (context) => const AddContactPage(),
      },
    );
  }
}



/*
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'home_page.dart';
import 'firebase_options.dart';
import 'login_page.dart';
import 'pages/add_contact_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, 
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Definindo as cores principais para facilitar o uso
    const Color deepNavy = Color(0xFF0A192F);
    const Color lightNavy = Color(0xFF112240); // Uma variação levemente mais clara para Cards

    return MaterialApp(
      title: 'Ark App',
      debugShowCheckedModeBanner: false,
      
      // CONFIGURAÇÃO DO TEMA DARK CUSTOMIZADO
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: deepNavy,
        
        // Cor principal para Botões e Destaques
        colorScheme: ColorScheme.dark(
          primary: const Color.fromARGB(255, 23, 226, 226),
          secondary: Colors.cyanAccent,
          surface: lightNavy,
          background: deepNavy,
        ),

        // Customização dos Textos
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white60),
        ),

        // Customização dos Botões (ElevatedButton)
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.cyanAccent,
            foregroundColor: deepNavy, // Texto do botão em azul escuro para contraste
            textStyle: const TextStyle(fontWeight: FontWeight.bold),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        // Customização das AppBar (Barras superiores)
        appBarTheme: const AppBarTheme(
          backgroundColor: deepNavy,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: TextStyle(
            color: Colors.cyanAccent,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
          iconTheme: IconThemeData(color: Colors.cyanAccent),
        ),

        // Customização das Caixas de Texto (TextFields)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: lightNavy,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          hintStyle: const TextStyle(color: Colors.white30),
          labelStyle: const TextStyle(color: Colors.cyanAccent),
        ),
      ),
      
      home: const LoginPage(),

      routes: {
        '/add_contact': (context) => const AddContactPage(),
      },
    );
  }
}
*/


