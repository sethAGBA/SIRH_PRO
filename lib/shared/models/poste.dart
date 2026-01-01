class Poste {
  const Poste({
    required this.id,
    required this.title,
    required this.departmentId,
    required this.departmentName,
    required this.level,
    required this.description,
    required this.code,
    this.typeContrat = '',
    this.localisation = '',
    this.salaireRange = '',
    this.missions = '',
    this.responsabilites = '',
    this.liensHierarchiques = '',
    this.formation = '',
    this.experience = '',
    this.competencesTech = '',
    this.competencesComport = '',
    this.langues = '',
    this.dureeCdd = '',
    this.avantages = '',
    this.datePrisePoste = '',
    this.sitesEmploi = '',
    this.reseauxSociaux = '',
    this.cooptationInterne = '',
    this.cabinets = '',
    this.status = 'Actif',
    this.deletedAt,
  });

  final String id;
  final String title;
  final String departmentId;
  final String departmentName;
  final String level;
  final String description;
  final String code;
  final String typeContrat;
  final String localisation;
  final String salaireRange;
  final String missions;
  final String responsabilites;
  final String liensHierarchiques;
  final String formation;
  final String experience;
  final String competencesTech;
  final String competencesComport;
  final String langues;
  final String dureeCdd;
  final String avantages;
  final String datePrisePoste;
  final String sitesEmploi;
  final String reseauxSociaux;
  final String cooptationInterne;
  final String cabinets;
  final String status;
  final int? deletedAt;
}
