import 'package:flutter/material.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/section_header.dart';
import '../../../shared/models/employe.dart';

class EmployeeDetailScreen extends StatelessWidget {
  const EmployeeDetailScreen({super.key, required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 7,
      child: Scaffold(
        appBar: AppBar(
          title: Text(employe.fullName),
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close),
            ),
          ],
          bottom: const TabBar(
            isScrollable: true,
            tabs: [
              Tab(text: 'Infos personnelles'),
              Tab(text: 'Carriere'),
              Tab(text: 'Contrats'),
              Tab(text: 'Formations'),
              Tab(text: 'Presences'),
              Tab(text: 'Remuneration'),
              Tab(text: 'Equipements'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _InfoPersonnellesTab(employe: employe),
            _CarriereTab(employe: employe),
            _ContratsTab(employe: employe),
            _FormationsTab(employe: employe),
            _PresencesTab(employe: employe),
            _RemunerationTab(employe: employe),
            _EquipementsTab(employe: employe),
          ],
        ),
      ),
    );
  }
}

class _InfoPersonnellesTab extends StatelessWidget {
  const _InfoPersonnellesTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Informations personnelles',
      subtitle: 'Etat civil, contacts et donnees bancaires.',
      sections: [
        _SectionContent(
          title: 'Etat civil',
          rows: [
            _FieldRow(label: 'Nom complet', value: employe.fullName),
            _FieldRow(label: 'Date naissance', value: _display(employe.dateNaissance)),
            _FieldRow(label: 'Lieu naissance', value: _display(employe.lieuNaissance)),
            _FieldRow(label: 'Nationalite', value: _display(employe.nationalite)),
            _FieldRow(label: 'Situation familiale', value: _display(employe.situationFamiliale)),
            _FieldRow(label: 'Etat civil detaille', value: _display(employe.etatCivilDetaille)),
            _FieldRow(label: 'Numero securite sociale', value: _display(employe.nir)),
          ],
        ),
        _SectionContent(
          title: 'Identite et contacts',
          rows: [
            _FieldRow(label: 'Matricule', value: employe.matricule),
            _FieldRow(label: 'Telephone', value: employe.phone),
            _FieldRow(label: 'Email', value: employe.email),
            _FieldRow(label: 'Adresse', value: _display(employe.adresse)),
            _FieldRow(label: 'Contact urgence', value: _display(employe.contactUrgence)),
          ],
        ),
        _SectionContent(
          title: 'Documents identite',
          rows: [
            _FieldRow(label: 'CNI', value: _display(employe.cni)),
            _FieldRow(label: 'Passeport', value: _display(employe.passeport)),
            _FieldRow(label: 'Permis', value: _display(employe.permis)),
            _FieldRow(label: 'Titre de sejour', value: _display(employe.titreSejour)),
          ],
        ),
        _SectionContent(
          title: 'Donnees bancaires',
          rows: [
            _FieldRow(label: 'RIB', value: _display(employe.rib)),
            _FieldRow(label: 'BIC', value: _display(employe.bic)),
            _FieldRow(label: 'Salaire verse', value: _display(employe.salaireVerse)),
          ],
        ),
        _SectionContent(
          title: 'Affectation',
          rows: [
            _FieldRow(label: 'Departement', value: employe.department),
            _FieldRow(label: 'Poste', value: employe.role),
            _FieldRow(label: 'Statut', value: employe.status),
          ],
        ),
      ],
    );
  }
}

class _CarriereTab extends StatelessWidget {
  const _CarriereTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Carriere professionnelle',
      subtitle: 'Historique de poste, promotions, objectifs.',
      sections: [
        _SectionContent(
          title: 'Historique postes',
          rows: [
            _FieldRow(label: 'Poste actuel', value: _display(employe.posteActuel)),
            _FieldRow(label: 'Poste precedent', value: _display(employe.postePrecedent)),
          ],
        ),
        _SectionContent(
          title: 'Organisation',
          rows: [
            _FieldRow(label: 'Manager direct', value: _display(employe.manager)),
            _FieldRow(label: 'Entite legale', value: _display(employe.entiteLegale)),
            _FieldRow(label: 'Site / etablissement', value: _display(employe.siteAffectation)),
            _FieldRow(label: 'Centre de cout', value: _display(employe.centreCout)),
          ],
        ),
        _SectionContent(
          title: 'Promotions et augmentations',
          rows: [
            _FieldRow(label: 'Derniere promotion', value: _display(employe.dernierePromotion)),
            _FieldRow(label: 'Augmentation', value: _display(employe.augmentation)),
          ],
        ),
        _SectionContent(
          title: 'Objectifs et evaluation',
          rows: [
            _FieldRow(label: 'Objectifs N+1', value: _display(employe.objectifs)),
            _FieldRow(label: 'Evaluation annuelle', value: _display(employe.evaluation)),
          ],
        ),
      ],
    );
  }
}

class _ContratsTab extends StatelessWidget {
  const _ContratsTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Contrats et documents',
      subtitle: 'Contrat en cours, avenants, documents RH.',
      sections: [
        _SectionContent(
          title: 'Contrat en cours',
          rows: [
            _FieldRow(label: 'Type', value: _display(employe.contractType)),
            _FieldRow(label: 'Date debut', value: _display(employe.contractStartDate)),
            _FieldRow(label: 'Date fin', value: _display(employe.contractEndDate)),
            _FieldRow(label: 'Statut', value: _display(employe.contractStatus)),
          ],
        ),
        _SectionContent(
          title: 'Conditions de travail',
          rows: [
            _FieldRow(label: 'Periode essai (duree)', value: _display(employe.periodeEssaiDuree)),
            _FieldRow(label: 'Periode essai (fin)', value: _display(employe.periodeEssaiFin)),
            _FieldRow(label: 'Temps de travail', value: _display(employe.tempsTravailType)),
            _FieldRow(label: 'Temps partiel (%)', value: _display(employe.tempsPartielPourcentage)),
            _FieldRow(label: 'Classification', value: _display(employe.classification)),
            _FieldRow(label: 'Coefficient', value: _display(employe.coefficient)),
            _FieldRow(label: 'Convention collective', value: _display(employe.conventionCollective)),
            _FieldRow(label: 'Statut cadre', value: _display(employe.statutCadre)),
          ],
        ),
        _SectionContent(
          title: 'Documents administratifs',
          rows: [
            _FieldRow(label: 'Avenants', value: _display(employe.avenants)),
            _FieldRow(label: 'Charte informatique', value: _display(employe.charteInformatique)),
            _FieldRow(label: 'Confidentialite', value: _display(employe.confidentialite)),
            _FieldRow(label: 'Clauses signees', value: _display(employe.clausesSignees)),
          ],
        ),
        _SectionContent(
          title: 'Documents obligatoires',
          rows: [
            _FieldRow(label: 'Carte vitale / attestation', value: _display(employe.carteVitale)),
            _FieldRow(label: 'Justificatif domicile', value: _display(employe.justificatifDomicile)),
            _FieldRow(label: 'Diplomes certifies', value: _display(employe.diplomesCertifies)),
            _FieldRow(label: 'Habilitations', value: _display(employe.habilitations)),
          ],
        ),
      ],
    );
  }
}

class _FormationsTab extends StatelessWidget {
  const _FormationsTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Formations et competences',
      subtitle: 'Diplomes, certifications, competences.',
      sections: [
        _SectionContent(
          title: 'Diplomes et certifications',
          rows: [
            _FieldRow(label: 'Dernier diplome', value: _display(employe.diplome)),
            _FieldRow(label: 'Certification', value: _display(employe.certification)),
          ],
        ),
        _SectionContent(
          title: 'Formations suivies',
          rows: [
            _FieldRow(label: 'Formations suivies', value: _listDisplay(employe.formationsSuivies)),
            _FieldRow(label: 'Formations planifiees', value: _listDisplay(employe.formationsPlanifiees)),
          ],
        ),
        _SectionContent(
          title: 'Competences et langues',
          rows: [
            _FieldRow(label: 'Techniques', value: _display(employe.competencesTech)),
            _FieldRow(label: 'Comportementales', value: _display(employe.competencesComport)),
            _FieldRow(label: 'Langues', value: _display(employe.langues)),
          ],
        ),
      ],
    );
  }
}

class _PresencesTab extends StatelessWidget {
  const _PresencesTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Presences et absences',
      subtitle: 'Pointages, retards, conges.',
      sections: [
        _SectionContent(
          title: 'Conges et soldes',
          rows: [
            _FieldRow(label: 'Conges restants', value: _display(employe.congesRestants)),
            _FieldRow(label: 'RTT restants', value: _display(employe.rttRestants)),
          ],
        ),
        _SectionContent(
          title: 'Absences',
          rows: [
            _FieldRow(label: 'Absences justifiees', value: _display(employe.absencesJustifiees)),
            _FieldRow(label: 'Retards', value: _display(employe.retards)),
          ],
        ),
        _SectionContent(
          title: 'Teletravail',
          rows: [
            _FieldRow(label: 'Jours autorises', value: _display(employe.teletravail)),
            _FieldRow(label: 'Dernier pointage', value: _display(employe.dernierPointage)),
          ],
        ),
        _SectionContent(
          title: 'Temps de travail',
          rows: [
            _FieldRow(label: 'Planning contractuel', value: _display(employe.planningContractuel)),
            _FieldRow(label: 'Quota heures', value: _display(employe.quotaHeures)),
            _FieldRow(label: 'Solde conges calcule', value: _display(employe.soldeCongesCalcule)),
            _FieldRow(label: 'RTT par periode', value: _display(employe.rttPeriode)),
          ],
        ),
      ],
    );
  }
}

class _RemunerationTab extends StatelessWidget {
  const _RemunerationTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Remuneration et avantages',
      subtitle: 'Salaire, primes, bulletins.',
      sections: [
        _SectionContent(
          title: 'Salaire et primes',
          rows: [
            _FieldRow(label: 'Salaire de base', value: _display(employe.salaireBase)),
            _FieldRow(label: 'Prime performance', value: _display(employe.primePerformance)),
          ],
        ),
        _SectionContent(
          title: 'Avantages',
          rows: [
            _FieldRow(label: 'Mutuelle', value: _display(employe.mutuelle)),
            _FieldRow(label: 'Ticket restaurant', value: _display(employe.ticketRestaurant)),
          ],
        ),
        _SectionContent(
          title: 'Bulletins',
          rows: [
            _FieldRow(label: 'Dernier bulletin', value: _display(employe.dernierBulletin)),
            _FieldRow(label: 'Historique', value: _display(employe.historiqueBulletins)),
          ],
        ),
        _SectionContent(
          title: 'Fiscalite et paiement',
          rows: [
            _FieldRow(label: 'Regime fiscal', value: _display(employe.regimeFiscal)),
            _FieldRow(label: 'Taux PAS', value: _display(employe.tauxPas)),
            _FieldRow(label: 'Mode paiement', value: _display(employe.modePaiement)),
            _FieldRow(label: 'Variables recurrentes', value: _display(employe.variablesRecurrence)),
          ],
        ),
      ],
    );
  }
}

class _EquipementsTab extends StatelessWidget {
  const _EquipementsTab({required this.employe});

  final Employe employe;

  @override
  Widget build(BuildContext context) {
    return _SectionedTab(
      title: 'Equipements et acces',
      subtitle: 'Materiel, badges, licences.',
      sections: [
        _SectionContent(
          title: 'Materiel attribue',
          rows: [
            _FieldRow(label: 'PC portable', value: _display(employe.pcPortable)),
            _FieldRow(label: 'Telephone', value: _display(employe.telephonePro)),
          ],
        ),
        _SectionContent(
          title: 'Acces et licences',
          rows: [
            _FieldRow(label: 'Badge acces', value: _display(employe.badgeAcces)),
            _FieldRow(label: 'Licence', value: _display(employe.licence)),
          ],
        ),
        _SectionContent(
          title: 'Conformite et securite',
          rows: [
            _FieldRow(label: 'Consentement RGPD', value: _display(employe.consentementRgpd)),
            _FieldRow(label: 'Habilitations systemes', value: _display(employe.habilitationsSystemes)),
            _FieldRow(label: 'Historique modifications', value: _display(employe.historiqueModifications)),
          ],
        ),
        _SectionContent(
          title: 'Sante et securite',
          rows: [
            _FieldRow(label: 'Visites medicales', value: _display(employe.visitesMedicales)),
            _FieldRow(label: 'Aptitude medicale', value: _display(employe.aptitudeMedicale)),
            _FieldRow(label: 'Restrictions poste', value: _display(employe.restrictionsPoste)),
          ],
        ),
      ],
    );
  }
}

class _SectionedTab extends StatelessWidget {
  const _SectionedTab({
    required this.title,
    required this.subtitle,
    required this.sections,
  });

  final String title;
  final String subtitle;
  final List<_SectionContent> sections;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionHeader(title: title, subtitle: subtitle),
          const SizedBox(height: 16),
          ...sections.map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _SectionCard(section: section),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section});

  final _SectionContent section;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            section.title,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: appTextPrimary(context),
            ),
          ),
          const SizedBox(height: 12),
          ...section.rows.map(
            (row) => _InfoRow(label: row.label, value: row.value),
          ),
        ],
      ),
    );
  }
}

class _SectionContent {
  const _SectionContent({required this.title, required this.rows});

  final String title;
  final List<_FieldRow> rows;
}

class _FieldRow {
  const _FieldRow({required this.label, required this.value});

  final String label;
  final String value;
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: TextStyle(color: appTextMuted(context)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: appTextPrimary(context),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

String _display(String value) {
  return value.isEmpty ? 'A definir' : value;
}

String _listDisplay(List<String> values) {
  return values.isEmpty ? 'A definir' : values.join(', ');
}
