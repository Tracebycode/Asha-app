import 'package:flutter/material.dart';
import 'package:asha_frontend/auth/session.dart';
import 'package:asha_frontend/features/family/ui/add_family_page.dart';
import 'package:asha_frontend/features/home/ui/family_details_page.dart';
import 'package:asha_frontend/debug/families_test.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();

    print("AUTO SESSION TEST ON APP START:");
    print("User ID: ${Session.instance.userId}");
    print("PHC ID: ${Session.instance.phcId}");
    print("Area ID: ${Session.instance.areaId}");
    print("ASHA Worker ID: ${Session.instance.ashaWorkerId}");
    print("ANM Worker ID: ${Session.instance.anmWorkerId}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A5A9E),
        title: const Text('ASHA Health Tracker', style: TextStyle(color: Colors.white)),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.person, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildUserInfo(),
            const SizedBox(height: 16),
            _buildDashboardGrid(context),
            const SizedBox(height: 16),
            _buildTasksFromSupervisor(context),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FamilyDetailsPage()),
          );
        },
        backgroundColor: const Color(0xFF2A5A9E),
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildUserInfo() {
    return Card(
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Rekha Sharma', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('Rampur Village', style: TextStyle(color: Colors.grey)),
              ],
            ),
            const Spacer(),
            Chip(
              avatar: const Icon(Icons.wifi, color: Colors.green, size: 16),
              label: const Text('Online', style: TextStyle(color: Colors.green)),
              backgroundColor: Colors.green.withOpacity(0.1),
              side: BorderSide.none,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardGrid(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      children: [
        _buildGridCard(
          context,
          icon: Icons.post_add,
          label: 'New Survey',
          sublabel: 'Start new data collection',
          color: Colors.blue,
          onTap: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => FamilyDetailsPage()));
          },
        ),
        _buildGridCard(
          context,
          icon: Icons.hourglass_top_outlined,
          label: 'Pending',
          sublabel: '3 Surveys',
          color: Colors.orange,
          onTap: () {},
        ),
        _buildGridCard(
          context,
          icon: Icons.check_circle_outline,
          label: 'Completed',
          sublabel: '15 Surveys',
          color: Colors.green,
          onTap: () {},
        ),
        _buildGridCard(
          context,
          icon: Icons.home_outlined,
          label: 'Households',
          sublabel: 'View all families',
          color: Colors.blue,
          onTap: () {},
        ),
        _buildGridCard(
          context,
          icon: Icons.sync,
          label: 'Sync Data',
          sublabel: 'Last: 10:30 AM',
          color: Colors.purple,
          onTap: () {},
        ),
        _buildGridCard(
          context,
          icon: Icons.notifications_active_outlined,
          label: 'Risk Alerts',
          sublabel: '2 New Alerts',
          color: Colors.red,
          isHighlighted: true,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildGridCard(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String sublabel,
        required Color color,
        required VoidCallback onTap,
        bool isHighlighted = false,
      }) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        side: isHighlighted ? const BorderSide(color: Colors.orange, width: 2) : BorderSide.none,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: const BorderRadius.all(Radius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 8),
              Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(sublabel, style: const TextStyle(color: Colors.grey, fontSize: 12)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTasksFromSupervisor(context) {
    return Card(
      elevation: 2.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.rule, color: Color(0xFF2A5A9E)),
                SizedBox(width: 16),
                Column(
                  children: [
                    Text('Tasks from Supervisor', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('1 New Task', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => FamiliesTest()));
              },
              child: const Text("Open Families Test"),
            ),
          ],
        ),
      ),
    );
  }
}
