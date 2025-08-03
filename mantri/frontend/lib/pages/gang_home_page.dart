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
  bool _hasUnreadMessages = false;
  String? _currentUserRole;
  Timer? _refreshTimer;
  Timer? _unreadCheckTimer;
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
    _unreadCheckTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (mounted && _gangId != null) {
        _loadGangData();
      }
    });

    _unreadCheckTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      if (mounted && _gangId != null) {
        _checkUnreadMessages();
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

        // Check for unread messages
        await _checkUnreadMessages();

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

  Future<void> _checkUnreadMessages() async {
    try {
      final messages = await ApiService.getChatMessages(_gangId!);
      final currentUser = await ApiService.getCurrentUser();

      // Check if there are any messages from other users after the last message from current user
      bool hasUnread = false;
      if (messages.isNotEmpty) {
        final lastMessage = messages.last;
        if (lastMessage['user']['id'] != currentUser['id']) {
          hasUnread = true;
        }
      }

      if (mounted) {
        setState(() {
          _hasUnreadMessages = hasUnread;
        });
      }
    } catch (e) {
      print('Error checking unread messages: $e');
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
          body: saved
              ? 'Great job! You saved today.'
              : 'Your save status has been updated.',
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
    final result = await ErrorHandler.handleAsyncOperation(context, () async {
      await ApiService.removeMember(_gangId!, userId);
      Navigator.pop(context);
      await _loadGangData();
      return true;
    }, successMessage: 'Member removed successfully');

    if (result == null) {
      // Error occurred, reload data to ensure UI is consistent
      await _loadGangData();
    }
  }

  Future<void> _leaveGang() async {
    if (_gangId == null) return;

    final result = await ErrorHandler.handleAsyncOperation(context, () async {
      await ApiService.leaveGang(_gangId!);
      return true;
    }, successMessage: 'Successfully left gang');

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
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Mantri and Gang Code side by side
          Row(
            children: [
              // Mantri Display
              if (_monthlyData != null && _monthlyData!['mantri'] != null)
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFFFE7743), Colors.red],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFE7743).withOpacity(0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.emoji_events,
                            color: Colors.white,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
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
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
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
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFF273F4F), Color(0xFF203E5F)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF273F4F).withOpacity(0.3),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.qr_code,
                          color: Colors.white,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
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
          const SizedBox(height: 24),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 70,
                        height: 70,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFFFE7743), Colors.red],
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFE7743).withOpacity(0.3),
                              blurRadius: 10,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            gang['name'][0].toUpperCase(),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              gang['name'],
                              style: const TextStyle(
                                fontSize: 26,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF273F4F),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              gang['description'],
                              style: const TextStyle(
                                color: Color(0xFF203E5F),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFEFEEEA),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(
                                        Icons.people,
                                        color: Color(0xFF273F4F),
                                        size: 18,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '${_gangData!['members'].length} members',
                                        style: const TextStyle(
                                          color: Color(0xFF273F4F),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Today\'s Save',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.green, Colors.greenAccent],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.green.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _saveToday(true),
                            icon: const Icon(Icons.check_circle, size: 24),
                            label: const Text(
                              'Yes',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [Colors.red, Colors.redAccent],
                            ),
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.red.withOpacity(0.3),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: ElevatedButton.icon(
                            onPressed: () => _saveToday(false),
                            icon: const Icon(Icons.cancel, size: 24),
                            label: const Text(
                              'No',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'This Week\'s Progress',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFEEEA),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(7, (index) {
                        final dayNames = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                        final isToday = index == DateTime.now().weekday - 1;
                        final isPast = index < DateTime.now().weekday - 1;
                        final isFuture = index > DateTime.now().weekday - 1;
                        final hasSaved =
                            index < userWeeklyRecord.length &&
                            userWeeklyRecord[index] == true;

                        IconData icon;
                        Color color;
                        String label = dayNames[index];

                        if (isFuture) {
                          icon = Icons.circle_outlined;
                          color = Colors.grey;
                        } else if (hasSaved) {
                          icon = Icons.check_circle;
                          color = Colors.green;
                        } else {
                          icon = Icons.cancel;
                          color = Colors.red;
                        }

                        return Column(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isToday
                                    ? const Color(0xFFFE7743)
                                    : Colors.transparent,
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                icon,
                                color: isToday ? Colors.white : color,
                                size: 24,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: TextStyle(
                                color: isToday
                                    ? const Color(0xFFFE7743)
                                    : const Color(0xFF273F4F),
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        );
                      }),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Weekly Leaderboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFEFEEEA)),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: weeklyRecords.length,
                      itemBuilder: (context, index) {
                        final record = weeklyRecords[index];
                        return Container(
                          decoration: BoxDecoration(
                            color: index == 0
                                ? const Color(0xFFEFEEEA)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFE7743),
                              child: Text(
                                record['username'][0].toUpperCase(),
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
                              '${record['week_saves'] ?? 0} saves this week',
                              style: const TextStyle(color: Color(0xFF203E5F)),
                            ),
                            trailing: index < 3
                                ? Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: index == 0
                                          ? Colors.red
                                          : index == 1
                                          ? Colors.grey[300]
                                          : const Color(0xFFFE7743),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Text(
                                      '${index + 1}',
                                      style: TextStyle(
                                        color: index == 0
                                            ? Colors.white
                                            : Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Monthly Leaderboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF273F4F),
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (_monthlyData != null &&
                      _monthlyData!['monthly_records'] != null)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFEFEEEA)),
                      ),
                      child: ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _monthlyData!['monthly_records'].length,
                        itemBuilder: (context, index) {
                          final record =
                              _monthlyData!['monthly_records'][index];
                          return Container(
                            decoration: BoxDecoration(
                              color: index == 0
                                  ? const Color(0xFFEFEEEA)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            margin: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFFFE7743),
                                child: Text(
                                  record['username'][0].toUpperCase(),
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
                                '${record['monthly_saves'] ?? 0} saves this month',
                                style: const TextStyle(
                                  color: Color(0xFF203E5F),
                                ),
                              ),
                              trailing: index < 3
                                  ? Container(
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: index == 0
                                            ? Colors.red
                                            : index == 1
                                            ? Colors.grey[300]
                                            : const Color(0xFFFE7743),
                                        shape: BoxShape.circle,
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: TextStyle(
                                          color: index == 0
                                              ? Colors.white
                                              : Colors.white,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                ],
              ),
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
        child: CircularProgressIndicator(color: Color(0xFFFE7743)),
      );
    }

    final members = List<Map<String, dynamic>>.from(_gangData!['members']);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFE7743),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(Icons.people, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              const Text(
                'Gang Members',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1A2634),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: members.length,
              itemBuilder: (context, index) {
                final member = members[index];
                return Container(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: index == 0
                        ? const Color(0xFFEFEEEA)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.red, Color(0xFFFE7743)],
                        ),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          member['user']['username'][0].toUpperCase(),
                          style: const TextStyle(
                            color: Color(0xFF1A2634),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    ),
                    title: Text(
                      member['user']['username'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A2634),
                        fontSize: 16,
                      ),
                    ),
                    subtitle: Text(
                      'Role: ${member['role']}',
                      style: const TextStyle(color: Color(0xFF203E5F)),
                    ),
                    trailing: member['role'] == 'host'
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Colors.red, Color(0xFFFE7743)],
                              ),
                              borderRadius: BorderRadius.circular(20),
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
                        ? Container(
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.remove_circle,
                                color: Colors.red,
                                size: 24,
                              ),
                              onPressed: () =>
                                  _removeMember(member['user']['id']),
                            ),
                          )
                        : null,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatTab() {
    return const Center(
      child: Text(
        'Chat',
        style: TextStyle(fontSize: 18, color: Color(0xFF203E5F)),
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
      _buildChatTab(),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFEFEEEA),
      appBar: AppBar(
        title: Text(
          _gangData?['gang']['name'] ?? 'Gang',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        backgroundColor: const Color(0xFF273F4F),
        elevation: 0,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF273F4F), Color(0xFF203E5F)],
            ),
          ),
        ),
        leading: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: IconButton(
              icon: const Icon(Icons.exit_to_app, color: Colors.white),
              onPressed: _leaveGang,
            ),
          ),
        ],
      ),
      body: tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF273F4F), Color(0xFF203E5F)],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            if (index == 2) {
              // Chat tab - directly navigate to chat
              setState(() {
                _hasUnreadMessages = false;
              });
              Navigator.pushNamed(context, '/chat', arguments: _gangId);
            } else {
              setState(() {
                _currentIndex = index;
              });
            }
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFFFE7743),
          unselectedItemColor: Colors.white70,
          elevation: 0,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.people),
              label: 'Members',
            ),
            BottomNavigationBarItem(
              icon: Stack(
                children: [
                  const Icon(Icons.chat),
                  if (_hasUnreadMessages)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: const Text(
                          '',
                          style: TextStyle(color: Colors.white, fontSize: 10),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              ),
              label: 'Chat',
            ),
          ],
        ),
      ),
    );
  }
}
