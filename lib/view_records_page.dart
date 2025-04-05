import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'database_helper.dart';

class ViewRecordsPage extends StatefulWidget {
  const ViewRecordsPage({Key? key}) : super(key: key);

  @override
  _ViewRecordsPageState createState() => _ViewRecordsPageState();
}

class _ViewRecordsPageState extends State<ViewRecordsPage> {
  String? loggedInUserId;
  List<Map<String, dynamic>> patientRecords = [];
  List<Map<String, dynamic>> filteredRecords = [];
  bool isLoading = true;
  bool showRecords = false;
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPatientRecords();
    searchController.addListener(_filterRecords);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  Future<void> fetchPatientRecords() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? userId = prefs.getString('loggedInUserEmail');
    debugPrint('🆔 [1/3] Retrieved from SharedPreferences - User Email: $userId');

    if (userId == null) {
      debugPrint('❌ [1/3] No user email found in SharedPreferences');
      setState(() => isLoading = false);
      return;
    }

    debugPrint('🔍 [2/3] Querying database for records...');
    List<Map<String, dynamic>> records = 
        await DatabaseHelper.instance.getPatientRecords(userId);

    debugPrint('📦 [3/3] Fetched ${records.length} records');
    if (records.isNotEmpty) {
      debugPrint('   First record sample:');
      debugPrint('   - Diagnosis: ${records.first['diagnosis']}');
      debugPrint('   - Date: ${records.first['visit_date']}');
    }

    setState(() {
      loggedInUserId = userId;
      patientRecords = records;
      filteredRecords = records;
      isLoading = false;
    });
  }

  void _filterRecords() {
    final query = searchController.text.toLowerCase();
    setState(() {
      filteredRecords = patientRecords.where((record) {
        return record['diagnosis'].toString().toLowerCase().contains(query) ||
               record['prescription'].toString().toLowerCase().contains(query) ||
               record['visit_date'].toString().toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('🔄 Building UI - Show records: $showRecords, Records count: ${filteredRecords.length}');
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Your Clinic Records'),
      ),
      body: Container(
        color: Colors.white,
        padding: EdgeInsets.all(16),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : Column(
                children: [
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        setState(() {
                          showRecords = !showRecords;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.lightBlueAccent,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        showRecords ? "Hide Records" : "View Your Records",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  AnimatedCrossFade(
                    duration: Duration(milliseconds: 300),
                    crossFadeState: showRecords
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    firstChild: SizedBox.shrink(),
                    secondChild: Column(
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                              labelText: 'Search Records',
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        filteredRecords.isEmpty
                            ? Center(
                                child: Text(
                                  "No Records Found",
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold),
                                ),
                              )
                            : Expanded(
                                child: ListView.builder(
                                  itemCount: filteredRecords.length,
                                  itemBuilder: (context, index) {
                                    var record = filteredRecords[index];
                                    debugPrint('🎯 Rendering record $index: ${record['diagnosis']}');
                                    return Card(
                                      margin: EdgeInsets.symmetric(vertical: 8),
                                      elevation: 2,
                                      child: ListTile(
                                        title: Text("Diagnosis: ${record['diagnosis']}"),
                                        subtitle: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text("Date: ${record['visit_date']}"),
                                            Text("Prescription: ${record['prescription']}"),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
                                ),
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