import 'package:sirhpro/core/database/sqlite_service.dart';

import 'avantage_dao.dart';
import 'competence_dao.dart';
import 'conge_dao.dart';
import 'contrat_dao.dart';
import 'departement_dao.dart';
import 'document_employe_dao.dart';
import 'employe_dao.dart';
import 'entretien_individuel_dao.dart';
import 'equipement_dao.dart';
import 'evaluation_dao.dart';
import 'formation_dao.dart';
import 'incident_accident_dao.dart';
import 'mobilite_interne_dao.dart';
import 'notes_frais_dao.dart';
import 'organigramme_dao.dart';
import 'paie_dao.dart';
import 'planning_horaire_dao.dart';
import 'poste_dao.dart';
import 'presence_dao.dart';
import 'recrutement_dao.dart';
import 'reporting_rh_dao.dart';
import 'sanction_dao.dart';
import 'parametres_entreprise_dao.dart';
import 'utilisateur_systeme_dao.dart';

class DaoRegistry {
  DaoRegistry({SQLiteService? sqlite}) : _sqlite = sqlite ?? SQLiteService() {
    employes = EmployeDao(sqlite: _sqlite);
    departements = DepartementDao(sqlite: _sqlite);
    postes = PosteDao(sqlite: _sqlite);
    contrats = ContratDao(sqlite: _sqlite);
    presences = PresenceDao(sqlite: _sqlite);
    conges = CongeDao(sqlite: _sqlite);
    formations = FormationDao(sqlite: _sqlite);
    evaluations = EvaluationDao(sqlite: _sqlite);
    competences = CompetenceDao(sqlite: _sqlite);
    recrutements = RecrutementDao(sqlite: _sqlite);
    paies = PaieDao(sqlite: _sqlite);
    avantages = AvantageDao(sqlite: _sqlite);
    sanctions = SanctionDao(sqlite: _sqlite);
    notesFrais = NotesFraisDao(sqlite: _sqlite);
    equipements = EquipementDao(sqlite: _sqlite);
    documents = DocumentEmployeDao(sqlite: _sqlite);
    organigramme = OrganigrammeDao(sqlite: _sqlite);
    plannings = PlanningHoraireDao(sqlite: _sqlite);
    incidents = IncidentAccidentDao(sqlite: _sqlite);
    entretiens = EntretienIndividuelDao(sqlite: _sqlite);
    mobilites = MobiliteInterneDao(sqlite: _sqlite);
    reporting = ReportingRhDao(sqlite: _sqlite);
    parametresEntreprise = ParametresEntrepriseDao(sqlite: _sqlite);
    utilisateurs = UtilisateurSystemeDao(sqlite: _sqlite);
  }

  final SQLiteService _sqlite;

  late final EmployeDao employes;
  late final DepartementDao departements;
  late final PosteDao postes;
  late final ContratDao contrats;
  late final PresenceDao presences;
  late final CongeDao conges;
  late final FormationDao formations;
  late final EvaluationDao evaluations;
  late final CompetenceDao competences;
  late final RecrutementDao recrutements;
  late final PaieDao paies;
  late final AvantageDao avantages;
  late final SanctionDao sanctions;
  late final NotesFraisDao notesFrais;
  late final EquipementDao equipements;
  late final DocumentEmployeDao documents;
  late final OrganigrammeDao organigramme;
  late final PlanningHoraireDao plannings;
  late final IncidentAccidentDao incidents;
  late final EntretienIndividuelDao entretiens;
  late final MobiliteInterneDao mobilites;
  late final ReportingRhDao reporting;
  late final ParametresEntrepriseDao parametresEntreprise;
  late final UtilisateurSystemeDao utilisateurs;

  static final DaoRegistry instance = DaoRegistry();
}
