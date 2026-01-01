class Recrutement {
  const Recrutement({
    required this.id,
    required this.candidatNom,
    required this.posteId,
    required this.posteNom,
    required this.status,
    required this.stage,
    required this.source,
    required this.score,
    required this.typeContrat,
    required this.email,
    required this.telephone,
    required this.localisation,
    required this.experience,
    required this.salaireSouhaite,
    required this.disponibilite,
    required this.entretienDate,
    required this.entretienLieu,
    required this.commentaire,
    required this.cvUrl,
  });

  final String id;
  final String candidatNom;
  final String posteId;
  final String posteNom;
  final String status;
  final String stage;
  final String source;
  final int score;
  final String typeContrat;
  final String email;
  final String telephone;
  final String localisation;
  final String experience;
  final String salaireSouhaite;
  final String disponibilite;
  final DateTime? entretienDate;
  final String entretienLieu;
  final String commentaire;
  final String cvUrl;
}
