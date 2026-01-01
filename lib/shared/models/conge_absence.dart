class CongeAbsence {
  const CongeAbsence({
    required this.id,
    required this.employeId,
    required this.employeName,
    required this.type,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.motif,
    required this.justificatif,
    required this.nbJours,
    required this.dateReprise,
    required this.interim,
    required this.contact,
    required this.commentaire,
    required this.decisionMotif,
    required this.history,
  });

  final String id;
  final String employeId;
  final String employeName;
  final String type;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String motif;
  final String justificatif;
  final double nbJours;
  final DateTime? dateReprise;
  final String interim;
  final String contact;
  final String commentaire;
  final String decisionMotif;
  final List<CongeHistoryEntry> history;
}

class CongeHistoryEntry {
  const CongeHistoryEntry({
    required this.title,
    required this.subtitle,
    required this.timestamp,
    required this.validator,
  });

  final String title;
  final String subtitle;
  final int timestamp;
  final String validator;

  Map<String, dynamic> toJson() => {
        'title': title,
        'subtitle': subtitle,
        'timestamp': timestamp,
        'validator': validator,
      };

  factory CongeHistoryEntry.fromJson(Map<String, dynamic> json) {
    return CongeHistoryEntry(
      title: (json['title'] as String?) ?? '',
      subtitle: (json['subtitle'] as String?) ?? '',
      timestamp: (json['timestamp'] as int?) ?? 0,
      validator: (json['validator'] as String?) ?? '',
    );
  }
}
