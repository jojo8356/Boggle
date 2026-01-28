import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/settings_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
        backgroundColor: Colors.purple,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SettingsService>(
        builder: (context, settings, child) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Section Durée de partie
              _buildSectionHeader('Durée de la partie'),
              const SizedBox(height: 8),
              _buildDurationSelector(context, settings),

              const SizedBox(height: 32),

              // Section Accessibilité
              _buildSectionHeader('Accessibilité'),
              const SizedBox(height: 8),
              _buildSeniorModeToggle(context, settings),

              const SizedBox(height: 32),

              // Section Zoom
              _buildSectionHeader('Zoom de la grille'),
              const SizedBox(height: 8),
              _buildZoomSlider(context, settings),

              const SizedBox(height: 16),
              _buildZoomPreview(settings),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.purple,
      ),
    );
  }

  Widget _buildSeniorModeToggle(BuildContext context, SettingsService settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SwitchListTile(
              title: const Text(
                'Mode Senior',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              subtitle: const Text(
                'Active un zoom plus grand (140%), une police plus lisible et un contraste augmenté',
                style: TextStyle(fontSize: 12),
              ),
              value: settings.seniorMode,
              activeTrackColor: Colors.purple[200],
              inactiveTrackColor: Colors.grey[300],
              onChanged: (value) {
                settings.setSeniorMode(value);
              },
            ),
            if (settings.seniorMode)
              Padding(
                padding: const EdgeInsets.only(top: 8, left: 16),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[600], size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Zoom automatique: ${settings.formatZoom(SettingsService.seniorModeZoom)}',
                      style: TextStyle(
                        color: Colors.green[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationSelector(BuildContext context, SettingsService settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Durée actuelle: ${settings.formatDuration(settings.gameDuration)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: SettingsService.durationOptions.map((duration) {
                final isSelected = settings.gameDuration == duration;
                return ChoiceChip(
                  label: Text(settings.formatDuration(duration)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      settings.setGameDuration(duration);
                    }
                  },
                  selectedColor: Colors.purple[200],
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomSlider(BuildContext context, SettingsService settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Zoom:', style: TextStyle(fontSize: 16)),
                Text(
                  settings.formatZoom(settings.gridZoom),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: settings.gridZoom,
              min: SettingsService.minZoom,
              max: SettingsService.maxZoom,
              divisions: 10,
              label: settings.formatZoom(settings.gridZoom),
              activeColor: Colors.purple,
              onChanged: (value) {
                settings.setGridZoom(value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  settings.formatZoom(SettingsService.minZoom),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
                Text(
                  settings.formatZoom(SettingsService.maxZoom),
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildZoomPreview(SettingsService settings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Aperçu:',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            Center(
              child: Transform.scale(
                scale: settings.gridZoom,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.amber[300]!, width: 2),
                  ),
                  child: GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: ['F', 'R', 'O', 'G', 'G', 'L', 'E', '!', '!']
                        .map((letter) => Container(
                              margin: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: Colors.amber[50],
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Center(
                                child: Text(
                                  letter,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
