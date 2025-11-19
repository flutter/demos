// Copyright 2025 Google LLC
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import 'package:flutter/material.dart';
import 'demos/chat/chat_demo.dart';
import 'demos/chat_nano/chat_nano_demo.dart';
import 'demos/multimodal/multimodal_demo.dart';
import 'demos/live_api/live_api_demo.dart';

class DemoHomeScreen extends StatefulWidget {
  const DemoHomeScreen({super.key});

  @override
  State<DemoHomeScreen> createState() => _DemoHomeScreenState();
}

class _DemoHomeScreenState extends State<DemoHomeScreen> {
  int _selectedIndex = 0;
  final List<({Widget icon, String label, Widget? selectedIcon})> destinations =
      [
        (icon: const Icon(Icons.chat), label: 'Chat', selectedIcon: null),
        (
          icon: const Icon(Icons.video_chat),
          label: 'Live API',
          selectedIcon: null,
        ),
        (
          icon: const Icon(Icons.photo_library),
          label: 'Multimodal',
          selectedIcon: null,
        ),
        (
          icon: RichText(
            text: const TextSpan(style: TextStyle(fontSize: 24.0), text: '🍌'),
          ),
          label: 'Nano Banana',
          selectedIcon: null,
        ),
      ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 600) {
          // Use BottomNavigationBar for smaller screens
          return Scaffold(
            body: demoPages[_selectedIndex],
            bottomNavigationBar: BottomNavigationBar(
              type: BottomNavigationBarType.fixed,
              items: destinations
                  .map(
                    (e) => BottomNavigationBarItem(
                      icon: e.icon,
                      label: e.label,
                      activeIcon: e.selectedIcon,
                    ),
                  )
                  .toList(),
              currentIndex: _selectedIndex,
              onTap: _onItemTapped,
            ),
          );
        } else {
          // Use NavigationRail for larger screens
          return Scaffold(
            body: Row(
              children: <Widget>[
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: _onItemTapped,
                  labelType: NavigationRailLabelType.all,
                  destinations: destinations
                      .map(
                        (e) => NavigationRailDestination(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          icon: e.icon,
                          label: Text(
                            e.label.replaceAll(' ', '\n'),
                            textAlign: TextAlign.center,
                          ),
                          selectedIcon: e.selectedIcon,
                        ),
                      )
                      .toList(),
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(child: demoPages[_selectedIndex]),
              ],
            ),
          );
        }
      },
    );
  }
}

final List<Widget> demoPages = <Widget>[
  const ChatDemo(),
  LiveAPIDemo(),
  const MultimodalDemo(),
  ChatDemoNano(),
];
