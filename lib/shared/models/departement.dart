class Departement {
  const Departement({
    required this.id,
    required this.name,
    required this.manager,
    this.managerId = '',
    required this.headcount,
    required this.budget,
    required this.pole,
    required this.size,
    required this.location,
    this.code = '',
    this.description = '',
    this.email = '',
    this.phone = '',
    this.extension = '',
    this.adresse = '',
    this.parentDepartement = '',
    this.parentDepartementId = '',
    this.dateCreation = '',
    this.notes = '',
    this.responsables = '',
    this.cadresCount = '',
    this.techniciensCount = '',
    this.supportCount = '',
    this.variationAnnuelle = '',
    this.tauxAbsenteisme = '',
    this.productiviteMoyenne = '',
    this.satisfactionEquipe = '',
    this.turnoverDepartement = '',
    this.budgetVsRealise = '',
    this.salairesTotaux = '',
    this.primesVariables = '',
    this.chargesSociales = '',
    this.coutMoyenEmploye = '',
    this.objectifPrincipal = '',
    this.indicateurObjectif = '',
    this.projetEnCours = '',
    this.ressourcesNecessaires = '',
    this.status = 'Actif',
    this.deletedAt,
  });

  final String id;
  final String name;
  final String manager;
  final String managerId;
  final int headcount;
  final String budget;
  final String pole;
  final String size;
  final String location;
  final String code;
  final String description;
  final String email;
  final String phone;
  final String extension;
  final String adresse;
  final String parentDepartement;
  final String parentDepartementId;
  final String dateCreation;
  final String notes;
  final String responsables;
  final String cadresCount;
  final String techniciensCount;
  final String supportCount;
  final String variationAnnuelle;
  final String tauxAbsenteisme;
  final String productiviteMoyenne;
  final String satisfactionEquipe;
  final String turnoverDepartement;
  final String budgetVsRealise;
  final String salairesTotaux;
  final String primesVariables;
  final String chargesSociales;
  final String coutMoyenEmploye;
  final String objectifPrincipal;
  final String indicateurObjectif;
  final String projetEnCours;
  final String ressourcesNecessaires;
  final String status;
  final int? deletedAt;
}
