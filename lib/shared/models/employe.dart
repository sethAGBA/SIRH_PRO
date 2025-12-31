class Employe {
  const Employe({
    required this.id,
    required this.matricule,
    required this.fullName,
    required this.department,
    required this.role,
    required this.contractType,
    required this.contractStatus,
    required this.tenure,
    required this.phone,
    required this.email,
    required this.skills,
    required this.hireDate,
    required this.status,
    this.dateNaissance = '',
    this.situationFamiliale = '',
    this.adresse = '',
    this.contactUrgence = '',
    this.cni = '',
    this.passeport = '',
    this.permis = '',
    this.rib = '',
    this.salaireVerse = '',
    this.posteActuel = '',
    this.postePrecedent = '',
    this.dernierePromotion = '',
    this.augmentation = '',
    this.objectifs = '',
    this.evaluation = '',
    this.contractStartDate = '',
    this.avenants = '',
    this.charteInformatique = '',
    this.confidentialite = '',
    this.diplome = '',
    this.certification = '',
    this.formationsSuivies = const [],
    this.formationsPlanifiees = const [],
    this.competencesTech = '',
    this.competencesComport = '',
    this.langues = '',
    this.congesRestants = '',
    this.rttRestants = '',
    this.absencesJustifiees = '',
    this.retards = '',
    this.teletravail = '',
    this.dernierPointage = '',
    this.salaireBase = '',
    this.primePerformance = '',
    this.mutuelle = '',
    this.ticketRestaurant = '',
    this.dernierBulletin = '',
    this.historiqueBulletins = '',
    this.pcPortable = '',
    this.telephonePro = '',
    this.badgeAcces = '',
    this.licence = '',
  });

  final String id;
  final String matricule;
  final String fullName;
  final String department;
  final String role;
  final String contractType;
  final String contractStatus;
  final String tenure;
  final String phone;
  final String email;
  final List<String> skills;
  final DateTime hireDate;
  final String status;
  final String dateNaissance;
  final String situationFamiliale;
  final String adresse;
  final String contactUrgence;
  final String cni;
  final String passeport;
  final String permis;
  final String rib;
  final String salaireVerse;
  final String posteActuel;
  final String postePrecedent;
  final String dernierePromotion;
  final String augmentation;
  final String objectifs;
  final String evaluation;
  final String contractStartDate;
  final String avenants;
  final String charteInformatique;
  final String confidentialite;
  final String diplome;
  final String certification;
  final List<String> formationsSuivies;
  final List<String> formationsPlanifiees;
  final String competencesTech;
  final String competencesComport;
  final String langues;
  final String congesRestants;
  final String rttRestants;
  final String absencesJustifiees;
  final String retards;
  final String teletravail;
  final String dernierPointage;
  final String salaireBase;
  final String primePerformance;
  final String mutuelle;
  final String ticketRestaurant;
  final String dernierBulletin;
  final String historiqueBulletins;
  final String pcPortable;
  final String telephonePro;
  final String badgeAcces;
  final String licence;
}
