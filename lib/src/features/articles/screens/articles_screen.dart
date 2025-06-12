import 'package:fintamer/src/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

class ArticlesScreen extends StatelessWidget {
  const ArticlesScreen({super.key});

  static const String routeName = '/articles';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.primaryColor,
        title: const Text('Статьи'),
      ),
      body: const Center(child: Text('Статьи')),
    );
  }
}
