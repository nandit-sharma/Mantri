import 'package:flutter/material.dart';
import '../services/api_service.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<Map<String, dynamic>> userGangs = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserGangs();
  }

  Future<void> _loadUserGangs() async {
    try {
      final gangs = await ApiService.getUserGangs();
      setState(() {
        userGangs = gangs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      // if (mounted) {
      //   ScaffoldMessenger.of(context).showSnackBar(
      //     SnackBar(
      //       content: Text('Failed to load gangs: ${e.toString()}'),
      //       backgroundColor: Colors.red,
      //     ),
      //   );
      // }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFEEEA),
      appBar: AppBar(
        title: const Text(
          'Monthly Leaderboards',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF273F4F),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFFFE7743)),
            )
          : userGangs.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.leaderboard, size: 64, color: Color(0xFF273F4F)),
                  SizedBox(height: 16),
                  Text(
                    'No gangs found',
                    style: TextStyle(fontSize: 18, color: Color(0xFF273F4F)),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Join or create a gang to see leaderboards',
                    style: TextStyle(fontSize: 14, color: Color(0xFF273F4F)),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: userGangs.length,
              itemBuilder: (context, index) {
                final gang = userGangs[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: InkWell(
                    onTap: () => _showGangLeaderboard(gang['gang_id']),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                radius: 25,
                                backgroundColor: const Color(0xFFFE7743),
                                child: Text(
                                  gang['name'][0].toUpperCase(),
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
                                      gang['name'],
                                      style: const TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xFF273F4F),
                                      ),
                                    ),
                                    Text(
                                      gang['description'],
                                      style: const TextStyle(
                                        color: Color(0xFF273F4F),
                                        fontSize: 14,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.people,
                                          color: Color(0xFF273F4F),
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          '${gang['member_count']} members',
                                          style: const TextStyle(
                                            color: Color(0xFF273F4F),
                                            fontSize: 12,
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 4,
                                          ),
                                          decoration: BoxDecoration(
                                            color: gang['role'] == 'host'
                                                ? const Color(0xFFFE7743)
                                                : Colors.grey[300],
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          child: Text(
                                            gang['role'].toUpperCase(),
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: gang['role'] == 'host'
                                                  ? Colors.white
                                                  : Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: Color(0xFF273F4F),
                                size: 16,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _showGangLeaderboard(String gangId) async {
    try {
      final monthlyData = await ApiService.getMonthlyLeaderboard(gangId);
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Monthly Leaderboard'),
            content: SizedBox(
              width: double.maxFinite,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (monthlyData['mantri'] != null)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFE7743),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.warning, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Our Mantri',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  monthlyData['mantri']['username'],
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (monthlyData['mantri'] != null) const SizedBox(height: 16),
                  Flexible(
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: monthlyData['monthly_records'].length,
                      itemBuilder: (context, index) {
                        final record = monthlyData['monthly_records'][index];
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
            content: Text('Failed to load leaderboard: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
