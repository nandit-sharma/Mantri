import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<Map<String, dynamic>> userGangs = [
    {'name': 'Gaming Squad', 'id': '12345', 'members': 8},
    {'name': 'Study Group', 'id': '67890', 'members': 12},
    {'name': 'Fitness Crew', 'id': '11111', 'members': 5},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: const Color(0xFFFEE5B1),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A2634),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Color(0xFFFFCC00)),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: Color(0xFFFFCC00)),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings - Feature coming soon')),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: Container(
          color: const Color(0xFF1A2634),
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              DrawerHeader(
                decoration: const BoxDecoration(color: Color(0xFF203E5F)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const CircleAvatar(
                      radius: 30,
                      backgroundColor: Color(0xFFFFCC00),
                      child: Icon(
                        Icons.person,
                        size: 35,
                        color: Color(0xFF1A2634),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'User Profile',
                      style: TextStyle(
                        color: Color(0xFFFFCC00),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'user@example.com',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.home, color: Color(0xFFFFCC00)),
                title: const Text(
                  'Home',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.group, color: Color(0xFFFFCC00)),
                title: const Text(
                  'My Gangs',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.settings, color: Color(0xFFFFCC00)),
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Settings - Feature coming soon'),
                    ),
                  );
                },
              ),
              const Divider(color: Color(0xFF203E5F)),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFFFCC00)),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Logout - Feature coming soon'),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '"My gang pees together, stays together..."',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2634),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        Navigator.pushNamed(context, '/create-gang'),
                    icon: const Icon(Icons.add),
                    label: const Text('Create Gang'),
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
                    onPressed: () => Navigator.pushNamed(context, '/join-gang'),
                    icon: const Icon(Icons.group_add),
                    label: const Text('Join Gang'),
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
            const SizedBox(height: 32),
            const Text(
              'Your Gangs',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A2634),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: userGangs.isEmpty
                  ? const Center(
                      child: Text(
                        'No gangs yet. Create or join a gang to get started!',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF203E5F),
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )
                  : ListView.builder(
                      itemCount: userGangs.length,
                      itemBuilder: (context, index) {
                        final gang = userGangs[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          color: Colors.white,
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(16),
                            leading: CircleAvatar(
                              backgroundColor: const Color(0xFFFFCC00),
                              child: Text(
                                gang['name'][0].toUpperCase(),
                                style: const TextStyle(
                                  color: Color(0xFF1A2634),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              gang['name'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1A2634),
                              ),
                            ),
                            subtitle: Text(
                              'ID: ${gang['id']} • ${gang['members']} members',
                              style: const TextStyle(color: Color(0xFF203E5F)),
                            ),
                            trailing: const Icon(
                              Icons.arrow_forward_ios,
                              color: Color(0xFF203E5F),
                            ),
                            onTap: () =>
                                Navigator.pushNamed(context, '/gang-home'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
