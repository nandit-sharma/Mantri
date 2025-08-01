import 'package:flutter/material.dart';
import '../services/api_service.dart';

class GangHomePage extends StatefulWidget {
  const GangHomePage({super.key});

  @override
  State<GangHomePage> createState() => _GangHomePageState();
}

class _GangHomePageState extends State<GangHomePage> {
  int _currentIndex = 0;
  Map<String, dynamic>? _gangData;
  bool _isLoading = true;
  String? _gangId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGangData();
    });
  }

  Future<void> _loadGangData() async {
    try {
      final args = ModalRoute.of(context)?.settings.arguments;
      print('Loading gang data with args: $args');
      if (args is String) {
        _gangId = args;
        print('Gang ID: $_gangId');
        final data = await ApiService.getGangHome(_gangId!);
        print('Received gang data: ${data.keys}');
        print('User weekly record: ${data['user_weekly_record']}');
        setState(() {
          _gangData = data;
          _isLoading = false;
        });
      } else {
        print('Invalid args type: ${args.runtimeType}');
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading gang data: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load gang data: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _saveToday(bool saved) async {
    if (_gangId == null) return;

    try {
      await ApiService.saveToday(_gangId!, saved);
      await _loadGangData();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              saved ? 'Daily save completed!' : 'Save status updated',
            ),
            backgroundColor: const Color(0xFF203E5F),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
    if (_gangData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF203E5F)),
      );
    }

    final gang = _gangData!['gang'];
    final userWeeklyRecord = List<dynamic>.from(
      _gangData!['user_weekly_record'],
    );
    final userTodaySave = _gangData!['user_today_save'] ?? false;
    final weeklyRecords = List<Map<String, dynamic>>.from(
      _gangData!['weekly_records'],
    );

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: const Color(0xFF203E5F),
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  const Text(
                    'Gang Code',
                    style: TextStyle(
                      color: Color(0xFFFFCC00),
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    gang['gang_id'] ?? 'N/A',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Share this code with others to join',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
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
                        child: Text(
                          gang['name'][0].toUpperCase(),
                          style: const TextStyle(
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
                            Text(
                              gang['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2634),
                              ),
                            ),
                            Text(
                              gang['description'],
                              style: const TextStyle(
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
                                  '${_gangData!['members'].length} members',
                                  style: const TextStyle(
                                    color: Color(0xFF203E5F),
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Icon(
                                  gang['is_public'] ? Icons.public : Icons.lock,
                                  color: const Color(0xFF203E5F),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  gang['is_public'] ? 'Public' : 'Private',
                                  style: const TextStyle(
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
                  const Text(
                    'Did you save today?',
                    style: TextStyle(fontSize: 16, color: Color(0xFF1A2634)),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveToday(true),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: userTodaySave
                                ? Colors.green
                                : Colors.grey[300],
                            foregroundColor: userTodaySave
                                ? Colors.white
                                : Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Yes',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () => _saveToday(false),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                !userTodaySave && userTodaySave != null
                                ? Colors.red
                                : Colors.grey[300],
                            foregroundColor:
                                !userTodaySave && userTodaySave != null
                                ? Colors.white
                                : Colors.grey[600],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'No',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userTodaySave
                        ? 'Great job! You\'ve saved today.'
                        : 'Don\'t forget to save today!',
                    style: TextStyle(
                      color: userTodaySave
                          ? const Color(0xFF203E5F)
                          : Colors.grey[600],
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'This Week\'s Record',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildDayRecord('Mon', userWeeklyRecord[0] as bool?, 0),
                      _buildDayRecord('Tue', userWeeklyRecord[1] as bool?, 1),
                      _buildDayRecord('Wed', userWeeklyRecord[2] as bool?, 2),
                      _buildDayRecord('Thu', userWeeklyRecord[3] as bool?, 3),
                      _buildDayRecord('Fri', userWeeklyRecord[4] as bool?, 4),
                      _buildDayRecord('Sat', userWeeklyRecord[5] as bool?, 5),
                      _buildDayRecord('Sun', userWeeklyRecord[6] as bool?, 6),
                    ],
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
              itemCount: weeklyRecords.length,
              itemBuilder: (context, index) {
                final sortedRecords = List<Map<String, dynamic>>.from(
                  weeklyRecords,
                )..sort((a, b) => b['week_saves'].compareTo(a['week_saves']));
                final record = sortedRecords[index];
                final rank = index + 1;

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
                    record['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  subtitle: Text(
                    '${record['week_saves']} saves this week',
                    style: const TextStyle(color: Color(0xFF203E5F)),
                  ),
                  trailing: record['role'] == 'host'
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

  Widget _buildDayRecord(String day, bool? saved, int dayIndex) {
    final now = DateTime.now();
    final today = now.weekday - 1;
    final isPastDay = dayIndex < today;
    final isToday = dayIndex == today;
    final isFutureDay = dayIndex > today;

    Widget iconWidget;
    Color backgroundColor;

    if (isFutureDay || saved == null) {
      backgroundColor = Colors.grey[300]!;
      iconWidget = const SizedBox();
    } else if (saved == true) {
      backgroundColor = Colors.green;
      iconWidget = const Icon(Icons.check, color: Colors.white, size: 20);
    } else {
      backgroundColor = Colors.red;
      iconWidget = const Icon(Icons.close, color: Colors.white, size: 20);
    }

    return Column(
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: backgroundColor,
            shape: BoxShape.circle,
          ),
          child: iconWidget,
        ),
        const SizedBox(height: 4),
        Text(
          day,
          style: const TextStyle(fontSize: 12, color: Color(0xFF203E5F)),
        ),
      ],
    );
  }

  Widget _buildMembersTab() {
    if (_gangData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF203E5F)),
      );
    }

    final members = List<Map<String, dynamic>>.from(_gangData!['members']);

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
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFFFFCC00),
                    child: Text(
                      member['user']['username'][0].toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF1A2634),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    member['user']['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  subtitle: Text(
                    'Role: ${member['role']}',
                    style: const TextStyle(color: Color(0xFF203E5F)),
                  ),
                  trailing: member['role'] == 'host'
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
            child: const Padding(
              padding: EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(Icons.timeline, size: 48, color: Color(0xFF203E5F)),
                  SizedBox(height: 16),
                  Text(
                    'Activity tracking coming soon!',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1A2634),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Track gang activities and achievements',
                    style: TextStyle(fontSize: 16, color: Color(0xFF203E5F)),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        backgroundColor: const Color(0xFFFEE5B1),
        appBar: AppBar(
          title: const Text(
            'Loading...',
            style: TextStyle(
              color: Color(0xFFFFCC00),
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: const Color(0xFF1A2634),
          elevation: 0,
          iconTheme: const IconThemeData(color: Color(0xFFFFCC00)),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFF203E5F)),
        ),
      );
    }

    final List<Widget> tabs = [
      _buildHomeTab(),
      _buildMembersTab(),
      _buildActivityTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFFEE5B1),
      appBar: AppBar(
        title: Text(
          _gangData?['gang']['name'] ?? 'Gang',
          style: const TextStyle(
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
            onPressed: () =>
                Navigator.pushNamed(context, '/chat', arguments: _gangId),
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
