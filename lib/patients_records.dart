import 'package:flutter/material.dart';
import 'package:med_track_a/database_helper.dart';
import 'package:logger/logger.dart';
import 'add_edit_patient.dart';
import 'models/patient.dart';

class PatientsRecords extends StatefulWidget {
  @override
  _PatientsRecordsState createState() => _PatientsRecordsState();
}

class _PatientsRecordsState extends State<PatientsRecords> {
  final Logger logger = Logger();
  List<Patient> _patients = [];
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchPatients();
  }

  Future<void> _fetchPatients() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final data = await DatabaseHelper.instance.fetchAllPatients();
      setState(() {
        _patients = data.map((e) => Patient.fromMap(e)).toList();
      });
    } catch (e) {
      logger.e("Failed to fetch patients: $e");
      setState(() => _hasError = true);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _editPatient(Patient patient) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddEditPatient(
          patientData: patient.toMap(),
        ),
      ),
    );

    if (result == true) {
      await _fetchPatients();
    }
  }

  Future<void> _deletePatient(Patient patient) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Confirm Deletion"),
        content: Text("Delete ${patient.name}'s records?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("OK", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await DatabaseHelper.instance.deletePatient(patient.id!);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Deleted ${patient.name}'s records")),
          );
          setState(() {
            _patients.removeWhere((p) => p.id == patient.id);
          });
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Failed to delete records")),
          );
        }
      }
    }
  }

  Widget _buildPatientCard(Patient patient) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      elevation: 2,
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        patient.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "ID: ${patient.idNumber} • ${patient.visitDate}",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _editPatient(patient),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deletePatient(patient),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 8),
            Text(
              "Diagnosis: ${patient.diagnosis}",
              style: TextStyle(fontSize: 14),
            ),
            SizedBox(height: 4),
            Text(
              "Prescription: ${patient.prescription}",
              style: TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Patient Records"),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _fetchPatients,
          ),
        ],
      ),
      body: _isLoading && _patients.isEmpty
          ? Center(child: CircularProgressIndicator())
          : _isLoading && _patients.isNotEmpty
              ? Stack(
                  children: [
                    RefreshIndicator(
                      onRefresh: _fetchPatients,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _patients.length,
                        itemBuilder: (_, index) => _buildPatientCard(_patients[index]),
                      ),
                    ),
                    Center(child: CircularProgressIndicator()),
                  ],
                )
          : _hasError
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Failed to load records"),
                      SizedBox(height: 10),
                      ElevatedButton(
                        onPressed: _fetchPatients,
                        child: Text("Retry"),
                      ),
                    ],
                  ),
                )
              : _patients.isEmpty
                  ? Center(child: Text("No patient records found"))
                  : RefreshIndicator(
                      onRefresh: _fetchPatients,
                      child: ListView.builder(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        itemCount: _patients.length,
                        itemBuilder: (_, index) => _buildPatientCard(_patients[index]),
                      ),
                    ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: () => _editPatient(Patient(
          id: null,
          name: '',
          age: 0,
          gender: '',
          idNumber: 0,
          phone: '',
          residence: '',
          visitDate: '',
          diagnosis: '',
          prescription: '',
          administration: '',
          duration: 0,
          paymentMethod: '',
          amountPaid: 0,
          balance: 0,
        )),
      ),
    );
  }
}