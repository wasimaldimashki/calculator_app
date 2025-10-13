import 'package:calculator_app/calc/cubit/calculator_cubit.dart';
import 'package:calculator_app/calc/presentation/calculator_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Calculator Application',
          theme: ThemeData(
            primarySwatch: Colors.blueGrey,
            brightness: Brightness.dark,
          ),
          home: BlocProvider(
            create: (context) => CalculatorCubit(),
            child: const CalculatorScreen(),
          ),
        );
      },
    );
  }
}
