import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final Map<String, dynamic> userProfile = {
    'name': 'John Doe',
    'email': 'john.doe@example.com',
    'avatar': 'J',
    'totalSaves': 45,
    'currentStreak': 7,
    'bestStreak': 14,
    'gangsJoined': 3,
    'achievements': [
      {
        'name': 'First Save',
        'description': 'Completed your first save',
        'date': '2024-01-15',
      },
      {
        'name': 'Week Warrior',
        'description': 'Saved for 7 consecutive days',
        'date': '2024-01-22',
      },
      {
        'name': 'Gang Leader',
        'description': 'Created your first gang',
        'date': '2024-01-10',
      },
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFEE5B1),
      appBar: AppBar(
        title: const Text(
          'Profile',
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
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundColor: const Color(0xFFFFCC00),
                      child: Text(
                        userProfile['avatar'],
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A2634),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      userProfile['name'],
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2634),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      userProfile['email'],
                      style: const TextStyle(
                        color: Color(0xFF203E5F),
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem(
                          'Total Saves',
                          userProfile['totalSaves'].toString(),
                        ),
                        _buildStatItem(
                          'Current Streak',
                          userProfile['currentStreak'].toString(),
                        ),
                        _buildStatItem(
                          'Best Streak',
                          userProfile['bestStreak'].toString(),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Statistics',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2634),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    _buildStatRow(
                      'Gangs Joined',
                      userProfile['gangsJoined'].toString(),
                      Icons.group,
                    ),
                    const Divider(),
                    _buildStatRow(
                      'Total Saves',
                      userProfile['totalSaves'].toString(),
                      Icons.save,
                    ),
                    const Divider(),
                    _buildStatRow(
                      'Current Streak',
                      '${userProfile['currentStreak']} days',
                      Icons.local_fire_department,
                    ),
                    const Divider(),
                    _buildStatRow(
                      'Best Streak',
                      '${userProfile['bestStreak']} days',
                      Icons.emoji_events,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Achievements',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2634),
              ),
            ),
            const SizedBox(height: 16),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: userProfile['achievements'].length,
              itemBuilder: (context, index) {
                final achievement = userProfile['achievements'][index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: Colors.white,
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFFFCC00),
                      child: const Icon(
                        Icons.emoji_events,
                        color: Color(0xFF1A2634),
                      ),
                    ),
                    title: Text(
                      achievement['name'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2634),
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          achievement['description'],
                          style: const TextStyle(color: Color(0xFF203E5F)),
                        ),
                        Text(
                          'Earned on ${achievement['date']}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edit Profile - Feature coming soon'),
                    ),
                  );
                },
                icon: const Icon(Icons.edit),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF203E5F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1A2634),
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Color(0xFF203E5F), fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildStatRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF203E5F), size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Color(0xFF1A2634), fontSize: 16),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A2634),
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
