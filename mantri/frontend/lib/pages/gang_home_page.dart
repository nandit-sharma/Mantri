import 'package:flutter/material.dart';

class GangHomePage extends StatefulWidget {
  const GangHomePage({super.key});

  @override
  State<GangHomePage> createState() => _GangHomePageState();
}

class _GangHomePageState extends State<GangHomePage> {
  final List<Map<String, dynamic>> gangMembers = [
    {'name': 'John Doe', 'role': 'Host', 'avatar': 'J'},
    {'name': 'Jane Smith', 'role': 'Member', 'avatar': 'J'},
    {'name': 'Mike Johnson', 'role': 'Member', 'avatar': 'M'},
    {'name': 'Sarah Wilson', 'role': 'Member', 'avatar': 'S'},
    {'name': 'Alex Brown', 'role': 'Member', 'avatar': 'A'},
  ];

  final List<Map<String, dynamic>> recentActivities = [
    {
      'type': 'message',
      'user': 'John Doe',
      'content': 'Welcome everyone!',
      'time': '2 min ago',
    },
    {
      'type': 'join',
      'user': 'Sarah Wilson',
      'content': 'joined the gang',
      'time': '1 hour ago',
    },
    {
      'type': 'event',
      'user': 'Mike Johnson',
      'content': 'created an event',
      'time': '3 hours ago',
    },
  ];

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

  void _openChat() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Chat - Feature coming soon')));
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _openChat,
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: Color(0xFFFFCC00)),
            onPressed: _showMoreOptions,
          ),
        ],
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
            const Text(
              'Members',
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
                      member['role'],
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
            const SizedBox(height: 24),
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
                            : Icons.event,
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
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Create Event - Feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.event),
                    label: const Text('Create Event'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: const Color(0xFF1A2634),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Share Gang - Feature coming soon'),
                        ),
                      );
                    },
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
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
          ],
        ),
      ),
    );
  }
}
