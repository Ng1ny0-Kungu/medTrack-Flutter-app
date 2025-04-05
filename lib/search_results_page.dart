import 'package:flutter/material.dart';
import 'package:med_track_a/database_helper.dart';
import 'package:med_track_a/models/patient.dart';
import 'package:med_track_a/add_edit_patient.dart';

class SearchResultsPage extends StatelessWidget {
  final String query;
  const SearchResultsPage({required this.query});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search Results")),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: DatabaseHelper.instance.searchPatients(query),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No results found for '$query'"));
          }
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final patient = Patient.fromMap(snapshot.data![index]);
              return Card(
                margin: EdgeInsets.all(8),
                child: ListTile(
                  title: Text(patient.name),
                  subtitle: Text("ID: ${patient.idNumber}"),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddEditPatient(patientData: patient.toMap()),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}