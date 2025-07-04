import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final _ipController = TextEditingController();
  final _portController = TextEditingController();
  final _adminPasswordController = TextEditingController();
  final _superAdminPasswordController = TextEditingController();

  bool _adminObscure = true;
  bool _superAdminObscure = true;

  @override
  void initState() {
    // TODO: implement initState
    _loadSavedIPAndPort();
    super.initState();
  }

  void _saveSettings() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('ip_address', _ipController.text);
      prefs.setString('port', _portController.text);
      prefs.setString('admin', _adminPasswordController.text);
      prefs.setString('superAdmin', _superAdminPasswordController.text);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings updated')));
    }
  }

  Future<void> _loadSavedIPAndPort() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _ipController.text = prefs.getString('ip_address') ?? '192.168.1.200';
      _portController.text = prefs.getString('port') ?? '502';
      _adminPasswordController.text = prefs.getString('admin') ?? 'admin';
      _superAdminPasswordController.text =
          prefs.getString('superAdmin') ?? 'qbase88';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // 👇 Your custom logic here
            Navigator.pop(context); // You can also return a result
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _ipController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'IP Address'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter IP address';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _portController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Port'),
                validator: (value) {
                  if (value == null || value.isEmpty)
                    return 'Please enter port';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _adminPasswordController,
                obscureText: _adminObscure,
                decoration: InputDecoration(
                  labelText: 'Admin Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _adminObscure ? Icons.visibility : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(() => _adminObscure = !_adminObscure),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _superAdminPasswordController,
                obscureText: _superAdminObscure,
                decoration: InputDecoration(
                  labelText: 'Super Admin Password',
                  suffixIcon: IconButton(
                    icon: Icon(
                      _superAdminObscure
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed:
                        () => setState(
                          () => _superAdminObscure = !_superAdminObscure,
                        ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('Save Settings'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
