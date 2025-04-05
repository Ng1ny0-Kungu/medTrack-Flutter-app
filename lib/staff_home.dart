import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:med_track_a/database_helper.dart';
import 'package:med_track_a/search_results_page.dart';
import 'package:med_track_a/add_edit_patient.dart';
import 'package:med_track_a/patients_records.dart';
import 'package:med_track_a/models/patient.dart';

class StaffHomePage extends StatefulWidget {
  const StaffHomePage({Key? key}) : super(key: key);

  @override
  _StaffHomePageState createState() => _StaffHomePageState();
}

class _StaffHomePageState extends State<StaffHomePage> {
  final TextEditingController searchController = TextEditingController();
  List<Map<String, dynamic>> recentRecords = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchRecentRecords();
  }

  Future<void> fetchRecentRecords() async {
    try {
      final records = await DatabaseHelper.instance.fetchRecentRecords();
      if (mounted) {
        setState(() {
          recentRecords = records;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => isLoading = false);
    }
  }

  void searchRecords() {
    final query = searchController.text.trim();
    if (query.isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SearchResultsPage(query: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFD580),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text("Staff Home Page", style: TextStyle(fontSize: 24)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Search Bar
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                  hintText: "Search patient",
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: const Icon(LucideIcons.search),
                    onPressed: searchRecords,
                  ),
                  border: InputBorder.none,
                ),
                onSubmitted: (_) => searchRecords(),
              ),
            ),

            const SizedBox(height: 20),

            // Add Patient Button
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEditPatient()),
              ).then((_) => fetchRecentRecords()),
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text("Add New Patient"),
            ),

            const SizedBox(height: 20),

            // Recent Records
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Recently Accessed Records", 
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 10),
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : recentRecords.isEmpty
                          ? const Center(child: Text("No recent records"))
                          : Expanded(
                              child: ListView.builder(
                                itemCount: recentRecords.length,
                                itemBuilder: (context, index) {
                                  final record = recentRecords[index];
                                  return ListTile(
                                    title: Text(record['name'] ?? ''),
                                    subtitle: Text("ID: ${record['id']}"),
                                    onTap: () async {
                                      final fullRecord = await DatabaseHelper.instance
                                          .fetchPatient(record['id']);
                                      if (fullRecord != null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) => AddEditPatient(
                                              patientData: fullRecord,
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                  // Add Patient Records Button
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => PatientsRecords()),
                        ),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue[50],
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue[100]!),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Patient's Records",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue[800],
                                ),
                              ),
                              Icon(Icons.arrow_forward, color: Colors.blue[800]),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}