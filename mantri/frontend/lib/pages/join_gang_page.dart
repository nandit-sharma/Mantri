import 'package:flutter/material.dart';

class JoinGangPage extends StatefulWidget {
  const JoinGangPage({super.key});

  @override
  State<JoinGangPage> createState() => _JoinGangPageState();
}

class _JoinGangPageState extends State<JoinGangPage> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  bool _isLoading = false;
  Map<String, dynamic>? _foundGang;

  void _searchGang() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      Future.delayed(const Duration(seconds: 1), () {
        setState(() {
          _isLoading = false;
          _foundGang = {
            'name': 'Gaming Squad',
            'description': 'A group for gaming enthusiasts',
            'members': 8,
            'isPublic': true,
            'host': 'John Doe',
          };
        });
      });
    }
  }

  void _requestToJoin() async {
    if (_foundGang != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request sent to join "${_foundGang!['name']}"'),
          backgroundColor: const Color(0xFF203E5F),
        ),
      );

      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _idController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE5B1),
      appBar: AppBar(
        title: const Text(
          'Join Gang',
          style: TextStyle(
            color: Color(0xFFFFCC00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A2634),
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFFFFCC00)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2634),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Ask the gang host for the 5-digit ID to join their gang',
                        style: TextStyle(
                          color: Color(0xFF203E5F),
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 24),
                      TextFormField(
                        controller: _idController,
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                        decoration: const InputDecoration(
                          labelText: 'Gang ID',
                          hintText: '12345',
                          border: OutlineInputBorder(),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Color(0xFF203E5F),
                              width: 2,
                            ),
                          ),
                          labelStyle: TextStyle(color: Color(0xFF203E5F)),
                          counterText: '',
                        ),
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
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _searchGang,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF203E5F),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white,
                                    ),
                                  ),
                                )
                              : const Text(
                                  'Search Gang',
                                  style: TextStyle(
                                    fontSize: 18,
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
                              backgroundColor: const Color(0xFFFFCC00),
                              child: Text(
                                _foundGang!['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1A2634),
                                  fontWeight: FontWeight.bold,
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
                                    'Hosted by ${_foundGang!['host']}',
                                    style: const TextStyle(
                                      color: Color(0xFF203E5F),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _foundGang!['description'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2634),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Icon(
                              Icons.people,
                              color: const Color(0xFF203E5F),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${_foundGang!['members']} members',
                              style: const TextStyle(
                                color: Color(0xFF203E5F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Icon(
                              _foundGang!['isPublic']
                                  ? Icons.public
                                  : Icons.lock,
                              color: const Color(0xFF203E5F),
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _foundGang!['isPublic'] ? 'Public' : 'Private',
                              style: const TextStyle(
                                color: Color(0xFF203E5F),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _requestToJoin,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFFFCC00),
                              foregroundColor: const Color(0xFF1A2634),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              'Request to Join',
                              style: TextStyle(
                                fontSize: 18,
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
