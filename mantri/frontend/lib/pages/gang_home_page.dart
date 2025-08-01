import 'package:flutter/material.dart';

class GangHomePage extends StatefulWidget {
  const GangHomePage({super.key});

  @override
  State<GangHomePage> createState() => _GangHomePageState();
}

class _GangHomePageState extends State<GangHomePage> {
  int _currentIndex = 0;
  final List<Map<String, dynamic>> gangMembers = [
    {
      'name': 'John Doe',
      'role': 'Host',
      'avatar': 'J',
      'saves': 5,
      'weekSaves': 3,
    },
    {
      'name': 'Jane Smith',
      'role': 'Member',
      'avatar': 'J',
      'saves': 8,
      'weekSaves': 6,
    },
    {
      'name': 'Mike Johnson',
      'role': 'Member',
      'avatar': 'M',
      'saves': 3,
      'weekSaves': 2,
    },
    {
      'name': 'Sarah Wilson',
      'role': 'Member',
      'avatar': 'S',
      'saves': 12,
      'weekSaves': 7,
    },
    {
      'name': 'Alex Brown',
      'role': 'Member',
      'avatar': 'A',
      'saves': 6,
      'weekSaves': 4,
    },
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {
      'type': 'achievement',
      'user': 'Sarah Wilson',
      'content': 'won Weekly Achievement: Most Saves!',
      'time': '2 hours ago',
    },
    {
      'type': 'save',
      'user': 'John Doe',
      'content': 'completed daily save',
      'time': '1 hour ago',
    },
    {
      'type': 'join',
      'user': 'Alex Brown',
      'content': 'joined the gang',
      'time': '3 hours ago',
    },
  ];

  bool _didSaveToday = false;
  DateTime _lastSaveDate = DateTime.now().subtract(const Duration(days: 1));

  @override
  void initState() {
    super.initState();
    _checkTodaySave();
  }

  void _checkTodaySave() {
    final today = DateTime.now();
    final lastSave = _lastSaveDate;
    _didSaveToday =
        today.year == lastSave.year &&
        today.month == lastSave.month &&
        today.day == lastSave.day;
  }

  void _toggleSave() {
    setState(() {
      _didSaveToday = !_didSaveToday;
      if (_didSaveToday) {
        _lastSaveDate = DateTime.now();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Daily save completed!'),
            backgroundColor: Color(0xFF203E5F),
          ),
        );
      }
    });
  }

  void _showMoreOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            ListTile(
              leading: const Icon(Icons.edit, color: Color(0xFF203E5F)),
              title: const Text('Edit Gang Info'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Edit Gang Info - Feature coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.people, color: Color(0xFF203E5F)),
              title: const Text('Manage Members'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Manage Members - Feature coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.event, color: Color(0xFF203E5F)),
              title: const Text('Create Event'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Create Event - Feature coming soon'),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF203E5F)),
              title: const Text('Gang Settings'),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Gang Settings - Feature coming soon'),
                  ),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.exit_to_app, color: Colors.red),
              title: const Text(
                'Leave Gang',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Leave Gang - Feature coming soon'),
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeTab() {
    return SingleChildScrollView(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: const Color(0xFFFFCC00),
                        child: const Text(
                          'G',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1A2634),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gaming Squad',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2634),
                              ),
                            ),
                            const Text(
                              'A group for gaming enthusiasts',
                              style: TextStyle(
                                color: Color(0xFF203E5F),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Color(0xFF203E5F),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${gangMembers.length} members',
                                  style: const TextStyle(
                                    color: Color(0xFF203E5F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.public,
                                  color: Color(0xFF203E5F),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Public',
                                  style: TextStyle(
                                    color: Color(0xFF203E5F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
                  const Text(
                    'Daily Check-in',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Checkbox(
                        value: _didSaveToday,
                        onChanged: (value) => _toggleSave(),
                        activeColor: const Color(0xFF203E5F),
                      ),
                      const Expanded(
                        child: Text(
                          'Did you save today?',
                          style: TextStyle(
                            fontSize: 16,
                            color: Color(0xFF1A2634),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _didSaveToday
                        ? 'Great job! You\'ve saved today.'
                        : 'Don\'t forget to save today!',
                    style: TextStyle(
                      color: _didSaveToday
                          ? const Color(0xFF203E5F)
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Weekly Leaderboard',
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gangMembers.length,
              itemBuilder: (context, index) {
                final member = gangMembers[index];
                final sortedMembers = List<Map<String, dynamic>>.from(
                  gangMembers,
                )..sort((a, b) => b['weekSaves'].compareTo(a['weekSaves']));
                final rank =
                    sortedMembers.indexWhere(
                      (m) => m['name'] == member['name'],
                    ) +
                    1;

                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: rank == 1
                        ? const Color(0xFFFFCC00)
                        : rank == 2
                        ? Colors.grey[400]
                        : rank == 3
                        ? Colors.brown[300]
                        : const Color(0xFF203E5F),
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Color(0xFF1A2634),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    member['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  subtitle: Text(
                    '${member['weekSaves']} saves this week',
                    style: const TextStyle(color: Color(0xFF203E5F)),
                  ),
                  trailing: member['role'] == 'Host'
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCC00),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2634),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMembersTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Gang Members',
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: gangMembers.length,
              itemBuilder: (context, index) {
                final member = gangMembers[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFCC00),
                    child: Text(
                      member['avatar'],
                      style: const TextStyle(
                        color: Color(0xFF1A2634),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    member['name'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  subtitle: Text(
                    '${member['saves']} total saves • ${member['weekSaves']} this week',
                    style: const TextStyle(color: Color(0xFF203E5F)),
                  ),
                  trailing: member['role'] == 'Host'
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFCC00),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1A2634),
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Recent Activity',
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
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: recentActivities.length,
              itemBuilder: (context, index) {
                final activity = recentActivities[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF203E5F),
                    child: Icon(
                      activity['type'] == 'message'
                          ? Icons.chat
                          : activity['type'] == 'join'
                          ? Icons.person_add
                          : activity['type'] == 'achievement'
                          ? Icons.emoji_events
                          : Icons.save,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  title: Text(
                    activity['user'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  subtitle: Text(
                    activity['content'],
                    style: const TextStyle(color: Color(0xFF203E5F)),
                  ),
                  trailing: Text(
                    activity['time'],
                    style: const TextStyle(
                      color: Color(0xFF203E5F),
                      fontSize: 12,
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> tabs = [
      _buildHomeTab(),
      _buildMembersTab(),
      _buildActivityTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFEE5B1),
      appBar: AppBar(
        title: const Text(
          'Gaming Squad',
          style: TextStyle(
            color: Color(0xFFFFCC00),
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF1A2634),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFFFFCC00)),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Color(0xFFFFCC00)),
            onPressed: () => Navigator.pushNamed(context, '/chat'),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFFCC00)),
            onPressed: _showMoreOptions,
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color(0xFF1A2634),
        selectedItemColor: const Color(0xFFFFCC00),
        unselectedItemColor: Colors.white70,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.people), label: 'Members'),
          BottomNavigationBarItem(
            icon: Icon(Icons.timeline),
            label: 'Activity',
          ),
        ],
      ),
    );
  }
}
