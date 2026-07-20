// Copyright 2026 The Flutter Authors.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme.dart';

class ScaffoldWithNavBar extends StatelessWidget {
  final StatefulNavigationShell navigationShell;

  const ScaffoldWithNavBar({required this.navigationShell, super.key});

  void _goBranch(int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          backgroundColor: CommisColors.surfaceLevel1,
          indicatorColor: CommisColors.goldAccent.withAlpha(30),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return GoogleFonts.sourceSans3(
                color: CommisColors.goldAccent,
                fontSize: 12.0,
                fontWeight: FontWeight.w700,
              );
            }
            return GoogleFonts.sourceSans3(
              color: CommisColors.textSecondary,
              fontSize: 12.0,
              fontWeight: FontWeight.w500,
            );
          }),
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: CommisColors.goldAccent);
            }
            return const IconThemeData(color: CommisColors.textSecondary);
          }),
        ),
        child: Container(
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: CommisColors.borderLowContrast,
                width: 1.0,
              ),
            ),
          ),
          child: NavigationBar(
            selectedIndex: navigationShell.currentIndex,
            onDestinationSelected: _goBranch,
            height: 70.0,
            labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.assignment_outlined),
                selectedIcon: Icon(Icons.assignment),
                label: 'Jobs',
              ),
              NavigationDestination(
                icon: Icon(Icons.restaurant_menu_outlined),
                selectedIcon: Icon(Icons.restaurant_menu),
                label: 'Recipes',
              ),
              NavigationDestination(
                icon: Icon(Icons.inventory_2_outlined),
                selectedIcon: Icon(Icons.inventory_2),
                label: 'Ingredients',
              ),
              NavigationDestination(
                icon: Icon(Icons.auto_awesome_outlined),
                selectedIcon: Icon(Icons.auto_awesome),
                label: 'Agent',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
