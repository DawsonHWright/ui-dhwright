import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Widget _menuButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    return SizedBox(
      width: 150,
      height: 120,
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, route);
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36),
            const SizedBox(height: 10),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Brain Test App'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 10),
            const Text(
              'Test Your Mind!',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 30),
            Expanded(
              child: Center(
                child: Wrap(
                  spacing: 20,
                  runSpacing: 20,
                  alignment: WrapAlignment.center,
                  children: [
                    _menuButton(
                      context: context,
                      icon: Icons.flash_on,
                      label: 'Reaction Time',
                      route: '/reaction',
                    ),
                    _menuButton(
                      context: context,
                      icon: Icons.psychology,
                      label: 'Memory Test',
                      route: '/memory',
                    ),
                    _menuButton(
                      context: context,
                      icon: Icons.grid_view,
                      label: 'Pattern Match',
                      route: '/pattern',
                    ),
                    _menuButton(
                      context: context,
                      icon: Icons.bar_chart,
                      label: 'Stats',
                      route: '/stats',
                    ),
                    _menuButton(
                      context: context,
                      icon: Icons.settings,
                      label: 'Settings',
                      route: '/settings',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}