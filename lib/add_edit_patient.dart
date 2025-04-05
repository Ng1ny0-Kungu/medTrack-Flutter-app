import 'package:flutter/material.dart';
import 'package:med_track_a/database_helper.dart';
import 'package:logger/logger.dart';
import 'package:flutter/services.dart';

class AddEditPatient extends StatefulWidget {
  final Map<String, dynamic>? patientData;
  AddEditPatient({this.patientData});
  
  @override
  _AddEditPatientState createState() => _AddEditPatientState();
}

class _AddEditPatientState extends State<AddEditPatient> {
  final _formKey = GlobalKey<FormState>();
  final Logger logger = Logger();
  
  // All TextEditingControllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _residenceController = TextEditingController();
  final TextEditingController _visitDateController = TextEditingController();
  final TextEditingController _diagnosisController = TextEditingController();
  final TextEditingController _prescriptionController = TextEditingController();
  final TextEditingController _administrationController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();
  final TextEditingController _paymentMethodController = TextEditingController();
  final TextEditingController _amountPaidController = TextEditingController();
  final TextEditingController _balanceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.patientData != null) {
      _populateFields(widget.patientData!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _idNumberController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _residenceController.dispose();
    _visitDateController.dispose();
    _diagnosisController.dispose();
    _prescriptionController.dispose();
    _administrationController.dispose();
    _durationController.dispose();
    _paymentMethodController.dispose();
    _amountPaidController.dispose();
    _balanceController.dispose();
    super.dispose();
  }

  void _populateFields(Map<String, dynamic> patientData) {
    _nameController.text = patientData['name'] ?? '';
    _ageController.text = patientData['age']?.toString() ?? '';
    _genderController.text = patientData['gender'] ?? '';
    _idNumberController.text = patientData['id_number']?.toString() ?? '';
    _phoneController.text = patientData['phone'] ?? '';
    _emailController.text = patientData['email'] ?? '';
    _residenceController.text = patientData['residence'] ?? '';
    _visitDateController.text = patientData['visit_date'] ?? '';
    _diagnosisController.text = patientData['diagnosis'] ?? '';
    _prescriptionController.text = patientData['prescription'] ?? '';
    _administrationController.text = patientData['administration'] ?? '';
    _durationController.text = patientData['duration']?.toString() ?? '';
    _paymentMethodController.text = patientData['payment_method'] ?? '';
    _amountPaidController.text = patientData['amount_paid']?.toString() ?? '';
    _balanceController.text = patientData['balance']?.toString() ?? '';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _visitDateController.text = picked.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _savePatient() async {
    if (!_formKey.currentState!.validate()) return;

    final patient = {
      'name': _nameController.text.trim(),
      'age': int.tryParse(_ageController.text.trim()) ?? 0,
      'gender': _genderController.text.trim(),
      'id_number': int.tryParse(_idNumberController.text.trim()) ?? 0,
      'phone': _phoneController.text.trim(),
      'email': _emailController.text.trim().isEmpty ? null : _emailController.text.trim(),
      'residence': _residenceController.text.trim(),
      'visit_date': _visitDateController.text.trim(),
      'diagnosis': _diagnosisController.text.trim(),
      'prescription': _prescriptionController.text.trim(),
      'administration': _administrationController.text.trim(),
      'duration': int.tryParse(_durationController.text.trim()) ?? 0,
      'payment_method': _paymentMethodController.text.trim(),
      'amount_paid': double.tryParse(_amountPaidController.text.trim()) ?? 0.0,
      'balance': double.tryParse(_balanceController.text.trim()) ?? 0.0,
    };

    try {
      if (widget.patientData == null) {
        await DatabaseHelper.instance.insertPatient(patient);
        logger.i("Patient added successfully");
      } else {
        await DatabaseHelper.instance.updatePatient(widget.patientData!['id'], patient);
        logger.i("Patient updated successfully");
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Patient record saved successfully!")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      logger.e("Failed to save patient: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error saving patient: ${e.toString()}")),
      );
    }
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(top: 16, bottom: 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String label,
    bool required, {
    bool isNumber = false,
    bool isEmail = false,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: inputFormatters,
        decoration: InputDecoration(
          labelText: label,
          border: OutlineInputBorder(),
        ),
        validator: (value) {
          if (required && (value == null || value.trim().isEmpty)) {
            return "$label is required";
          }
          if (isNumber && double.tryParse(value!) == null) {
            return "Enter a valid number";
          }
          if (isEmail && !value!.contains("@")) {
            return "Enter a valid email";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _visitDateController,
        readOnly: true,
        decoration: InputDecoration(
          labelText: "Visit Date",
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
        ),
        onTap: () => _selectDate(context),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "Visit date is required";
          }
          return null;
        },
      ),
    );
  }

  Widget _buildGenderDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _genderController.text.isEmpty ? null : _genderController.text,
        items: ["Male", "Female"].map((gender) {
          return DropdownMenuItem(
            value: gender,
            child: Row(
              children: [
                Radio<String>(
                  value: gender,
                  groupValue: _genderController.text,
                  onChanged: (value) {
                    setState(() => _genderController.text = value!);
                  },
                ),
                Text(gender),
              ],
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: "Gender",
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null ? "Select gender" : null,
        onChanged: (value) {
          setState(() => _genderController.text = value!);
        },
      ),
    );
  }

  Widget _buildPaymentMethodDropdown() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8),
      child: DropdownButtonFormField<String>(
        value: _paymentMethodController.text.isEmpty ? null : _paymentMethodController.text,
        items: ["M-PESA", "Bank", "Cash"].map((method) {
          return DropdownMenuItem(
            value: method,
            child: Row(
              children: [
                Radio<String>(
                  value: method,
                  groupValue: _paymentMethodController.text,
                  onChanged: (value) {
                    setState(() => _paymentMethodController.text = value!);
                  },
                ),
                Text(method),
              ],
            ),
          );
        }).toList(),
        decoration: InputDecoration(
          labelText: "Payment Method",
          border: OutlineInputBorder(),
        ),
        validator: (value) => value == null ? "Select payment method" : null,
        onChanged: (value) {
          setState(() => _paymentMethodController.text = value!);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.patientData == null ? "Add Patient" : "Edit Patient"),
      ),
      body: Padding(
        padding: EdgeInsets.all(12),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildSectionHeader("Personal Information"),
              _buildTextField(_nameController, "Full Name", true),
              _buildTextField(_ageController, "Age", true, isNumber: true),
              _buildGenderDropdown(),
              _buildTextField(_idNumberController, "ID Number", true, isNumber: true),
              _buildTextField(_phoneController, "Phone Number", true),
              _buildTextField(_emailController, "Email", false),
              _buildTextField(_residenceController, "Residence", true),

              _buildSectionHeader("Medical Information"),
              _buildDateField(context),
              _buildTextField(_diagnosisController, "Diagnosis", true),
              _buildTextField(_prescriptionController, "Prescription", true),
              _buildTextField(
                _administrationController, 
                "Administration", 
                true,
                inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z0-9\s]'))],
              ),
              _buildTextField(_durationController, "Duration (Days)", true, isNumber: true),

              _buildSectionHeader("Payment Information"),
              _buildPaymentMethodDropdown(),
              _buildTextField(_amountPaidController, "Amount Paid (KES)", true, isNumber: true),
              _buildTextField(_balanceController, "Balance (KES)", true, isNumber: true),

              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _savePatient,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 15),
                  minimumSize: Size(double.infinity, 50),
                ),
                child: Text(
                  "Save",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}