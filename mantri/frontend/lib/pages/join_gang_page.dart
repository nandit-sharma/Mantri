import 'package:flutter/material.dart';
import '../services/api_service.dart';

class JoinGangPage extends StatefulWidget {
  const JoinGangPage({super.key});

  @override
  State<JoinGangPage> createState() => _JoinGangPageState();
}

class _JoinGangPageState extends State<JoinGangPage> {
  final _formKey = GlobalKey<FormState>();
  final _gangIdController = TextEditingController();
  Map<String, dynamic>? _foundGang;
  bool _isLoading = false;
  bool _isSearching = false;

  @override
  void dispose() {
    _gangIdController.dispose();
    super.dispose();
  }

  Future<void> _searchGang() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isSearching = true;
        _foundGang = null;
      });

      try {
        final gang = await ApiService.getGang(_gangIdController.text.trim());
        setState(() {
          _foundGang = gang;
          _isSearching = false;
        });
      } catch (e) {
        setState(() {
          _foundGang = null;
          _isSearching = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gang not found: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _requestToJoin() async {
    if (_foundGang != null) {
      setState(() {
        _isLoading = true;
      });

      try {
        await ApiService.joinGang(_foundGang!['gang_id']);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Successfully joined "${_foundGang!['name']}"'),
              backgroundColor: const Color(0xFFFE7743),
            ),
          );
          await Future.delayed(const Duration(seconds: 1));
          if (mounted) {
            Navigator.pop(context);
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to join gang: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEEEA),
      appBar: AppBar(
        title: const Text(
          'Join Gang',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF273F4F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Card(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Enter Gang ID',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2634),
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _gangIdController,
                        decoration: const InputDecoration(
                          labelText: '5-digit Gang ID',
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.group),
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a gang ID';
                          }
                          if (value.length != 5) {
                            return 'Gang ID must be 5 digits';
                          }
                          if (!RegExp(r'^\d{5}$').hasMatch(value)) {
                            return 'Gang ID must contain only numbers';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isSearching ? null : _searchGang,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF203E5F),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isSearching
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : const Text(
                                  'Search Gang',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_foundGang != null) ...[
                const SizedBox(height: 24),
                Card(
                  color: Colors.white,
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 25,
                              backgroundColor: Colors.red,
                              child: Text(
                                _foundGang!['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _foundGang!['name'],
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF1A2634),
                                    ),
                                  ),
                                  Text(
                                    _foundGang!['description'],
                                    style: const TextStyle(
                                      color: Color(0xFF203E5F),
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              _foundGang!['is_public']
                                  ? Icons.public
                                  : Icons.lock,
                              color: const Color(0xFF203E5F),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _foundGang!['is_public'] ? 'Public' : 'Private',
                              style: const TextStyle(
                                color: Color(0xFF203E5F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _requestToJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: _isLoading
                                ? const CircularProgressIndicator(
                                    color: Color(0xFF1A2634),
                                  )
                                : const Text(
                                    'Request to Join',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
