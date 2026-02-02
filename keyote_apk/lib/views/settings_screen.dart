import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/settings_viewmodel.dart';
import '../viewmodels/keyboard_viewmodel.dart';
import '../utils/validators.dart';
import '../utils/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final _ipController = TextEditingController();
  final _portController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final viewModel = context.read<SettingsViewModel>();
    _ipController.text = viewModel.ip;
    _portController.text = viewModel.port.toString();
  }

  @override
  void dispose() {
    _ipController.dispose();
    _portController.dispose();
    super.dispose();
  }

  Future<void> _saveSettings() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<SettingsViewModel>();
    viewModel.updateIp(_ipController.text);
    viewModel.updatePort(_portController.text);

    final success = await viewModel.saveSettings();

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            success ? 'Settings saved successfully' : 'Failed to save settings',
          ),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );
    }
  }

  Future<void> _testConnection() async {
    if (!_formKey.currentState!.validate()) return;

    final viewModel = context.read<SettingsViewModel>();
    viewModel.updateIp(_ipController.text);
    viewModel.updatePort(_portController.text);

    await viewModel.testConnection();

    if (mounted) {
      final isConnected = viewModel.isConnected;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isConnected ? 'Connection successful!' : 'Connection failed',
          ),
          backgroundColor: isConnected ? Colors.green : Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<SettingsViewModel>();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Server Configuration',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _ipController,
                          decoration: const InputDecoration(
                            labelText: 'Laptop IP Address',
                            hintText: '192.168.x.x',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.computer),
                          ),
                          keyboardType: TextInputType.number,
                          validator: Validators.validateIp,
                        ),

                        const SizedBox(height: 16),

                        TextFormField(
                          controller: _portController,
                          decoration: const InputDecoration(
                            labelText: 'Port',
                            hintText: '5000',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.settings_ethernet),
                          ),
                          keyboardType: TextInputType.number,
                          validator: Validators.validatePort,
                        ),

                        const SizedBox(height: 24),

                        Row(
                          children: [
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: viewModel.isTesting
                                    ? null
                                    : _testConnection,
                                icon: viewModel.isTesting
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor:
                                              AlwaysStoppedAnimation<Color>(
                                                Colors.white,
                                              ),
                                        ),
                                      )
                                    : const Icon(Icons.wifi_find),
                                label: Text(
                                  viewModel.isTesting
                                      ? 'Testing...'
                                      : 'Test Connection',
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: FilledButton.icon(
                                onPressed: _saveSettings,
                                icon: const Icon(Icons.save),
                                label: const Text('Save'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Appearance', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 16),

                        SwitchListTile(
                          title: const Text('Dark Mode'),
                          subtitle: const Text(
                            'Toggle between light and dark theme',
                          ),
                          value: viewModel.themeMode == ThemeMode.dark,
                          onChanged: (_) => viewModel.toggleTheme(),
                          secondary: Icon(
                            viewModel.themeMode == ThemeMode.dark
                                ? Icons.dark_mode
                                : Icons.light_mode,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Sound Settings',
                          style: theme.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        SwitchListTile(
                          title: const Text('Key Press Sound'),
                          subtitle: const Text(
                            'Enable or disable sound feedback',
                          ),
                          value: viewModel.soundEnabled,
                          onChanged: (value) =>
                              viewModel.updateSoundEnabled(value),
                          secondary: Icon(
                            viewModel.soundEnabled
                                ? Icons.volume_up
                                : Icons.volume_off,
                          ),
                        ),

                        const SizedBox(height: 8),

                        ListTile(
                          leading: const Icon(Icons.music_note),
                          title: const Text('Sound Type'),
                          subtitle: DropdownButton<String>(
                            value: viewModel.selectedSound,
                            isExpanded: true,
                            items: AppConstants.soundLabels.entries.map((
                              entry,
                            ) {
                              return DropdownMenuItem<String>(
                                value: entry.key,
                                child: Row(
                                  children: [
                                    Text(entry.value),
                                    const SizedBox(width: 8),
                                    if (viewModel.selectedSound == entry.key)
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                        size: 16,
                                      ),
                                  ],
                                ),
                              );
                            }).toList(),
                            onChanged: (String? newValue) async {
                              if (newValue != null) {
                                await viewModel.updateSelectedSound(newValue);
                                // Notify keyboard viewmodel to reload sound
                                if (mounted) {
                                  context.read<KeyboardViewModel>().reloadSoundSettings();
                                }
                              }
                            },
                          ),
                        ),

                        const SizedBox(height: 16),

                        ListTile(
                          leading: const Icon(Icons.volume_up),
                          title: const Text('Volume'),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Slider(
                                      value: viewModel.soundVolume,
                                      min: AppConstants.minVolume,
                                      max: AppConstants.maxVolume,
                                      divisions: 20,
                                      label: '${(viewModel.soundVolume * 100).round()}%',
                                      onChanged: (double value) async {
                                        await viewModel.updateSoundVolume(value);
                                        // Notify keyboard viewmodel to update volume
                                        if (mounted) {
                                          context.read<KeyboardViewModel>().reloadSoundSettings();
                                        }
                                      },
                                      onChangeEnd: (double value) {
                                        // Play preview at selected volume
                                        viewModel.playPreview(viewModel.selectedSound);
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  SizedBox(
                                    width: 45,
                                    child: Text(
                                      '${(viewModel.soundVolume * 100).round()}%',
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About', style: theme.textTheme.titleLarge),
                        const SizedBox(height: 16),

                        const ListTile(
                          leading: Icon(Icons.info_outline),
                          title: Text('Version'),
                          subtitle: Text('1.0.0'),
                        ),

                        const ListTile(
                          leading: Icon(Icons.keyboard),
                          title: Text('Keyote Remote'),
                          subtitle: Text('Remote keyboard for USB tethering'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
