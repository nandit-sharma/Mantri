import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../services/settings_service.dart';
import '../services/error_handler.dart';
import 'dart:async';

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
  Map<String, dynamic>? _monthlyData;
  String? _currentUserRole;
  Timer? _refreshTimer;
  final SettingsService _settingsService = SettingsService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadGangData();
    });
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _gangId != null) {
        _loadGangData();
      }
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

        // Get current user's role
        final members = List<Map<String, dynamic>>.from(data['members']);
        final currentUser = await ApiService.getCurrentUser();
        final currentMember = members.firstWhere(
          (member) => member['user']['id'] == currentUser['id'],
          orElse: () => {'role': 'member'},
        );
        _currentUserRole = currentMember['role'];

        // Load monthly leaderboard
        await _loadMonthlyData();

        if (mounted) {
          setState(() {
            _gangData = data;
            _isLoading = false;
          });
        }
      } else {
        print('Invalid args type: ${args.runtimeType}');
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error loading gang data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ErrorHandler.showError(context, ErrorHandler.getErrorMessage(e));
      }
    }
  }

  Future<void> _loadMonthlyData() async {
    try {
      final monthlyData = await ApiService.getMonthlyLeaderboard(_gangId!);
      setState(() {
        _monthlyData = monthlyData;
      });
    } catch (e) {
      print('Error loading monthly data: $e');
    }
  }

  Future<void> _saveToday(bool saved) async {
    if (_gangId == null) return;

    final result = await ErrorHandler.handleAsyncOperation(
      context,
      () async {
        await ApiService.saveToday(_gangId!, saved);
        await _loadGangData();
        
        // Show notification if enabled
        await _settingsService.showNotification(
          title: saved ? 'Daily Save Completed!' : 'Save Status Updated',
          body: saved ? 'Great job! You saved today.' : 'Your save status has been updated.',
        );
        
        return true;
      },
      successMessage: saved ? 'Daily save completed!' : 'Save status updated',
    );

    if (result == null) {
      // Error occurred, reload data to ensure UI is consistent
      await _loadGangData();
    }
  }

  Future<void> _manageMembers() async {
    if (_gangId == null) return;

    try {
      final members = await ApiService.getGangMembers(_gangId!);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Manage Members'),
            content: SizedBox(
              width: double.maxFinite,
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: members.length,
                itemBuilder: (context, index) {
                  final member = members[index];
                  return ListTile(
                    title: Text(member['user']['username']),
                    subtitle: Text(member['role']),
                    trailing: member['role'] != 'host'
                        ? IconButton(
                            icon: const Icon(
                              Icons.remove_circle,
                              color: Colors.red,
                            ),
                            onPressed: () =>
                                _removeMember(member['user']['id']),
                          )
                        : null,
                  );
                },
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to load members: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _removeMember(int userId) async {
    final result = await ErrorHandler.handleAsyncOperation(
      context,
      () async {
        await ApiService.removeMember(_gangId!, userId);
        Navigator.pop(context);
        await _loadGangData();
        return true;
      },
      successMessage: 'Member removed successfully',
    );

    if (result == null) {
      // Error occurred, reload data to ensure UI is consistent
      await _loadGangData();
    }
  }

  Future<void> _leaveGang() async {
    if (_gangId == null) return;

    final result = await ErrorHandler.handleAsyncOperation(
      context,
      () async {
        await ApiService.leaveGang(_gangId!);
        return true;
      },
      successMessage: 'Successfully left gang',
    );

    if (result != null && mounted) {
      Navigator.pop(context);
    }
  }

  Widget _buildHomeTab() {
    if (_gangData == null) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFFFE7743)),
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
          // Mantri and Gang Code side by side
          Row(
            children: [
              // Mantri Display
              if (_monthlyData != null && _monthlyData!['mantri'] != null)
                Expanded(
                  child: Card(
                    color: const Color(0xFFFE7743),
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          const Text(
                            'Our Mantri',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _monthlyData!['mantri']['username'],
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Needs to improve',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              if (_monthlyData != null && _monthlyData!['mantri'] != null)
                const SizedBox(width: 16),
              // Gang Code
              Expanded(
                child: Card(
                  color: const Color(0xFF273F4F),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        const Text(
                          'Gang Code',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          gang['gang_id'] ?? 'N/A',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 2,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Share to join',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
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
                        backgroundColor: const Color(0xFFFE7743),
                        child: Text(
                          gang['name'][0].toUpperCase(),
                          style: const TextStyle(
                            fontSize: 24,
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
                              gang['name'],
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF273F4F),
                              ),
                            ),
                            Text(
                              gang['description'],
                              style: const TextStyle(
                                color: Color(0xFF273F4F),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(
                                  Icons.people,
                                  color: Color(0xFF273F4F),
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  '${_gangData!['members'].length} members',
                                  style: const TextStyle(
                                    color: Color(0xFF273F4F),
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
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Did you save today?',
                    style: TextStyle(fontSize: 16, color: Color(0xFF273F4F)),
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
                            backgroundColor: !userTodaySave
                                ? Colors.red
                                : Colors.grey[300],
                            foregroundColor: !userTodaySave
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
                    'This Week\'s Record',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  const SizedBox(height: 16),
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
              color: Color(0xFF273F4F),
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
                        ? const Color(0xFFFE7743)
                        : rank == 2
                        ? Colors.grey[400]
                        : rank == 3
                        ? Colors.brown[300]
                        : const Color(0xFF273F4F),
                    child: Text(
                      rank.toString(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    record['username'],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  subtitle: Text(
                    '${record['week_saves']} saves this week',
                    style: const TextStyle(color: Color(0xFF273F4F)),
                  ),
                  trailing: record['role'] == 'host'
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFE7743),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(
                            'HOST',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        )
                      : null,
                );
              },
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Monthly Leaderboard',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF273F4F),
            ),
          ),
          const SizedBox(height: 16),
          if (_monthlyData != null)
            Card(
              color: Colors.white,
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _monthlyData!['monthly_records'].length,
                itemBuilder: (context, index) {
                  final record = _monthlyData!['monthly_records'][index];
                  final rank = index + 1;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: rank == 1
                          ? const Color(0xFFFE7743)
                          : rank == 2
                          ? Colors.grey[400]
                          : rank == 3
                          ? Colors.brown[300]
                          : const Color(0xFF273F4F),
                      child: Text(
                        rank.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      record['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF273F4F),
                      ),
                    ),
                    subtitle: Text(
                      '${record['monthly_saves']} saves this month',
                      style: const TextStyle(color: Color(0xFF273F4F)),
                    ),
                    trailing: record['role'] == 'host'
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFE7743),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'HOST',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
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
                      : _currentUserRole == 'host'
                      ? IconButton(
                          icon: const Icon(
                            Icons.remove_circle,
                            color: Colors.red,
                          ),
                          onPressed: () => _removeMember(member['user']['id']),
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
        backgroundColor: const Color(0xFFEFEEEA),
        appBar: AppBar(
          title: const Text(
            'Loading...',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: const Color(0xFF273F4F),
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFFE7743)),
        ),
      );
    }

    final List<Widget> tabs = [
      _buildHomeTab(),
      _buildMembersTab(),
      _buildActivityTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFEEEA),
      appBar: AppBar(
        title: Text(
          _gangData?['gang']['name'] ?? 'Gang',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF273F4F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () =>
                Navigator.pushNamed(context, '/chat', arguments: _gangId),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app, color: Colors.white),
            onPressed: _leaveGang,
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
        backgroundColor: const Color(0xFF273F4F),
        selectedItemColor: const Color(0xFFFE7743),
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
