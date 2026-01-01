class ParametresEntreprise {
  const ParametresEntreprise({
    required this.id,
    required this.raisonSociale,
    required this.adresse,
    required this.telephone,
    required this.email,
    required this.rccm,
    required this.nif,
    required this.website,
    required this.logoPath,
    required this.directeurNom,
    required this.localisation,
    required this.siret,
    required this.conventionCollective,
  });

  final String id;
  final String raisonSociale;
  final String adresse;
  final String telephone;
  final String email;
  final String rccm;
  final String nif;
  final String website;
  final String logoPath;
  final String directeurNom;
  final String localisation;
  final String siret;
  final String conventionCollective;

  ParametresEntreprise copyWith({
    String? id,
    String? raisonSociale,
    String? adresse,
    String? telephone,
    String? email,
    String? rccm,
    String? nif,
    String? website,
    String? logoPath,
    String? directeurNom,
    String? localisation,
    String? siret,
    String? conventionCollective,
  }) {
    return ParametresEntreprise(
      id: id ?? this.id,
      raisonSociale: raisonSociale ?? this.raisonSociale,
      adresse: adresse ?? this.adresse,
      telephone: telephone ?? this.telephone,
      email: email ?? this.email,
      rccm: rccm ?? this.rccm,
      nif: nif ?? this.nif,
      website: website ?? this.website,
      logoPath: logoPath ?? this.logoPath,
      directeurNom: directeurNom ?? this.directeurNom,
      localisation: localisation ?? this.localisation,
      siret: siret ?? this.siret,
      conventionCollective: conventionCollective ?? this.conventionCollective,
    );
  }
}
