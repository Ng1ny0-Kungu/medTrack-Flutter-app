class Patient {
  final int? id;
  final String name;
  final int age;
  final String gender;
  final int idNumber;
  final String phone;
  final String? email;
  final String residence;
  final String visitDate;
  final String diagnosis;
  final String prescription;
  final String administration;
  final int duration;
  final String paymentMethod;
  final double amountPaid;
  final double balance;

  Patient({
    this.id,
    required this.name,
    required this.age,
    required this.gender,
    required this.idNumber,
    required this.phone,
    this.email,
    required this.residence,
    required this.visitDate,
    required this.diagnosis,
    required this.prescription,
    required this.administration,
    required this.duration,
    required this.paymentMethod,
    required this.amountPaid,
    required this.balance,
  });

  factory Patient.fromMap(Map<String, dynamic> map) => Patient(
        id: map['id'],
        name: map['name'],
        age: map['age'],
        gender: map['gender'],
        idNumber: map['id_number'],
        phone: map['phone'],
        email: map['email'],
        residence: map['residence'],
        visitDate: map['visit_date'],
        diagnosis: map['diagnosis'],
        prescription: map['prescription'],
        administration: map['administration'],
        duration: map['duration'],
        paymentMethod: map['payment_method'],
        amountPaid: map['amount_paid'],
        balance: map['balance'],
      );

  Map<String, dynamic> toMap() => {
        if (id != null) 'id': id,
        'name': name,
        'age': age,
        'gender': gender,
        'id_number': idNumber,
        'phone': phone,
        'email': email,
        'residence': residence,
        'visit_date': visitDate,
        'diagnosis': diagnosis,
        'prescription': prescription,
        'administration': administration,
        'duration': duration,
        'payment_method': paymentMethod,
        'amount_paid': amountPaid,
        'balance': balance,
      };
}