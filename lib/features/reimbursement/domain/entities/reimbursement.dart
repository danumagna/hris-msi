/// Represents a reimbursement entry in the domain layer.
class Reimbursement {
  final String id;
  final String title;
  final ReimburseType type;
  final String subType;
  final DateTime transactionStartDate;
  final DateTime transactionEndDate;
  final String description;
  final DateTime entryTime;
  final double amount;
  final List<String> filePaths;
  final String status;
  final String? rejectionReason;

  const Reimbursement({
    required this.id,
    required this.title,
    required this.type,
    required this.subType,
    required this.transactionStartDate,
    required this.transactionEndDate,
    required this.description,
    required this.entryTime,
    required this.amount,
    required this.filePaths,
    this.status = 'Waiting for approval',
    this.rejectionReason,
  });
}

enum ReimburseType {
  medical('Medical'),
  transport('Transport'),
  operational('Operational'),
  entertainment('Entertainment'),
  other('Other');

  final String label;
  const ReimburseType(this.label);
}

/// Maps each [ReimburseType] to its available sub-types.
const Map<ReimburseType, List<String>> reimburseSubTypes = {
  ReimburseType.medical: [
    'Doctor',
    'Medicine',
    'Doctor & Medicine',
    'Lab Test',
    'Hospital',
    'Eyeglass Frame',
    'Eyeglass Lens',
    'Eyeglass Frame & Lens',
  ],
  ReimburseType.transport: ['Online Transport', 'Parking', 'Fuel', 'Toll Fee'],
  ReimburseType.entertainment: ['Client Meal', 'Coffee Meeting'],
  ReimburseType.operational: [
    'Laptop Accessories',
    'Printing/Photocopy',
    'Courier/Delivery',
    'Internet',
  ],
  ReimburseType.other: ['Special Request'],
};
