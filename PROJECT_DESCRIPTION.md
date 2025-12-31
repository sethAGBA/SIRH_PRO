# Application de Gestion des Ressources Humaines (SIRH)

Système d'information complet en Flutter Desktop avec SQLite (mode offline).

## Architecture technique
- Base de données SQLite.
- Tables principales :
  - `employes`, `departements`, `postes`, `contrats`, `presences`, `conges_absences`
  - `formations`, `evaluations_performance`, `competences`, `recrutements`
  - `paie_salaires`, `avantages_sociaux`, `sanctions_avertissements`, `notes_frais`
  - `equipements_materiel`, `documents_employes`, `organigramme`, `plannings_horaires`
  - `incidents_accidents`, `entretiens_individuels`, `mobilite_interne`
  - `reporting_rh`, `parametres_entreprise`, `utilisateurs_systeme`

## Structure de navigation
- Sidebar : navigation principale entre modules RH.
- AppBar : actions rapides et profil utilisateur.
- Body : zone de contenu avec onglets contextuels.
- Bottom Bar : notifications RH et statistiques temps réel.

## Modules & ecrans

### 1. Tableau de bord RH
- Indicateurs : effectifs, absences, formations, teletravail.
- Graphiques : evolution 12 mois, pyramide des ages, anciennete.
- Alertes : fins de periodes d'essai, renouvellements, formations expirees.
- Actions rapides : FAB "Nouvel employe", recherche globale, notifications.

### 2. Gestion des employes
- Registre : DataTable (photo, matricule, departement, poste, statut, anciennete).
- Filtres : departement, type contrat, statut, date embauche.
- Actions en lot : export trombinoscope, badges, attestations.
- Dossier employe par onglets (infos personnelles, carriere, contrats, formations, presences, remuneration, equipements).
- Formulaire nouvel employe : wizard, validation temps reel, generation matricule, creation compte, checklist onboarding.

### 3. Gestion des departements
- Cards departement : nom, manager, effectif, budget.
- Organigramme interactif avec export PDF/PNG et drag & drop.
- Detail departement : equipe, performance, masse salariale, objectifs.

### 4. Gestion des presences
- Tableau de bord pointages : vue jour/mois, stats, anomalies.
- Pointage employe : badgeage, manuel, teletravail, ajustements.
- Gestion horaires : horaires contractuels, planning, compteurs temps, analyse presence.

### 5. Gestion conges & absences
- Workflow demande : N+1 -> RH -> confirmation.
- Calendrier et alertes chevauchements.
- Compteurs : CP, RTT, maladie, conges speciaux.

### 6. Gestion recrutement
- Pipeline : CV recus -> preselection -> entretien -> offre -> embauche.
- Fiche poste : description, profil, conditions, diffusion.
- Onboarding : checklist, formation initiale, suivi periode d'essai.

### 7. Formations & developpement
- Plan annuel, budget, calendrier.
- Catalogue : obligatoires, metier, developpement, langues.
- Sessions : inscriptions, convocations, evaluations, attestations.

### 8. Evaluations & performance
- Campagnes annuelles avec relances.
- Dossier entretien : bilan, competences, objectifs, developpement, remuneration.
- 9-Box et revue des talents.

### 9. Paie & remuneration
- Import variables, calcul cotisations, generation bulletins, DSN.
- Elements variables : primes, indemnites, avantages.
- Historique remuneration et benchmarks.

### 10. Notes de frais
- Statuts demandes, controles, barremes et plafonds.
- Circuit validation hierarchique et comptable.

### 11. Discipline & sanctions
- Registre disciplinaire, procedure legale, archivage.
- Dossier incident : faits, employe, procedure, decision.

### 12. Accidents & medecine du travail
- Declaration AT/MP, suivi arrets, prevention risques.
- Dossier sante : visites, vaccinations, aptitudes.

### 13. Comptabilite RH
- Masse salariale, provisions, budget vs realise.
- Declarations sociales et ratios financiers.

### 14. Reporting & statistiques RH
- Indicateurs effectifs, sociaux, formation, paie.
- Rapports reglmentaires (bilan social, index egalite, BDES).
- Exports PDF/Excel/CSV et planification.

### 15. Parametres & administration
- Configuration entreprise, grilles salariales, templates.
- Profils acces : admin RH, DRH, RH, paie, managers, employes.
- Conformite & audit : logs, RGPD, sauvegardes, archivage.

## Maquettes
- Une maquette texte est en cours d'elaboration pour l'ecran Dashboard RH.

## Application de Gestion des Ressources Humaines (SIRH)
Système d'Information Complet
Flutter Desktop + SQLite (Mode Offline)
 
🏗️ Architecture Technique
Base de données SQLite
Tables principales:
•	employes (informations personnelles et professionnelles)
•	departements (services et divisions de l'entreprise)
•	postes (fonctions et descriptions)
•	contrats (types et conditions d'emploi)
•	presences (pointages et horaires)
•	conges_absences (demandes et validations)
•	formations (plans et historiques)
•	evaluations_performance (entretiens et objectifs)
•	competences (savoir-faire et certifications)
•	recrutements (candidatures et processus)
•	paie_salaires (bulletins et primes)
•	avantages_sociaux (mutuelle, tickets, primes)
•	sanctions_avertissements
•	notes_frais (remboursements et justificatifs)
•	equipements_materiel (attribution et suivi)
•	documents_employes (contrats, attestations)
•	organigramme (hiérarchie et rattachements)
•	plannings_horaires
•	incidents_accidents (déclarations AT/MP)
•	entretiens_individuels
•	mobilite_interne (mutations, promotions)
•	reporting_rh (statistiques et tableaux de bord)
•	parametres_entreprise
•	utilisateurs_systeme
Structure de navigation
•	Sidebar : Navigation principale entre modules RH
•	AppBar : Barre d'outils avec actions rapides et profil utilisateur
•	Body : Zone de contenu avec onglets contextuels
•	Bottom Bar : Notifications RH et statistiques temps réel
 
📱 Modules & Écrans Détaillés
🔹 1. TABLEAU DE BORD RH
Écran principal avec indicateurs clés
Widgets dashboard:
•	Effectifs du jour : Présents, absents, en congé, en formation, en télétravail
•	Graphiques : Évolution effectifs 12 mois, pyramide des âges, ancienneté moyenne
•	Alertes critiques : Fin périodes d'essai, renouvellements contrats, formations obligatoires expirées
•	Indicateurs de performance : Taux d'absentéisme, turn-over, satisfaction employés
•	Agenda RH : Entretiens programmés, recrutements, formations, événements
Actions rapides:
•	Bouton FAB : "Nouvel employé"
•	Barre de recherche globale (employé/département/poste)
•	Notifications système (anniversaires, alertes documents)
•	Statut temps réel des départements
 
🔹 2. GESTION DES EMPLOYÉS
Écran principal : Registre du personnel
•	DataTable avec colonnes : Photo, Matricule, Nom complet, Département, Poste, Statut contrat, Ancienneté, Actions
•	Filtres : Par département, type contrat (CDI/CDD/Stage), statut (actif/suspendu/parti), date d'embauche
•	Recherche avancée : Nom, matricule, téléphone, email, compétences
•	Actions en lot : Export trombinoscope, génération badges, attestations employeur
Écran détail employé (Dossier personnel complet)
Tabs:
├── 📋 Informations personnelles
│   ├── État civil (nom, prénom, date naissance)
│   ├── Photo d'identité professionnelle
│   ├── Pièces d'identité (CNI, passeport, permis)
│   ├── Adresse complète et contacts
│   ├── Situation familiale (conjoint, enfants)
│   ├── Personnes à contacter en urgence
│   └── Données bancaires (RIB, salaire)
│
├── 💼 Carrière professionnelle
│   ├── Historique postes occupés
│   ├── Promotions et augmentations
│   ├── Mutations entre départements
│   ├── Évaluations annuelles
│   ├── Objectifs et réalisations
│   └── Plan de développement carrière
│
├── 📄 Contrats & Documents
│   ├── Contrat de travail en cours
│   ├── Avenants et modifications
│   ├── Historique des contrats
│   ├── Clause de confidentialité
│   ├── Charte informatique signée
│   └── Documents administratifs
│
├── 🎓 Formations & Compétences
│   ├── Diplômes et certifications
│   ├── Formations suivies
│   ├── Formations programmées
│   ├── Compétences techniques
│   ├── Compétences comportementales
│   └── Langues parlées (niveaux)
│
├── 📅 Présences & Absences
│   ├── Historique pointages
│   ├── Heures travaillées vs théoriques
│   ├── Retards et absences
│   ├── Congés pris et soldes
│   ├── Arrêts maladie
│   └── Télétravail effectué
│
├── 💰 Rémunération & Avantages
│   ├── Salaire de base
│   ├── Primes et bonus
│   ├── Bulletins de paie
│   ├── Avantages en nature
│   ├── Mutuelle et prévoyance
│   └── Historique augmentations
│
└── 📊 Équipements & Accès
    ├── Matériel attribué (PC, téléphone)
    ├── Badges et clés d'accès
    ├── Logiciels et licences
    ├── Véhicule de fonction
    └── Outils professionnels
Formulaire nouvel employé
•	Wizard en étapes : Identification → Contrat → Affectation → Équipements
•	Validation temps réel des champs
•	Vérification absence doublons (email, numéro sécu)
•	Génération automatique matricule employé
•	Création compte utilisateur système
•	Checklist intégration (onboarding)
 
🔹 3. GESTION DES DÉPARTEMENTS
Écran organisation de l'entreprise
•	Cards département avec : Nom, Manager, Effectif, Budget masse salariale
•	Filtres : Par pôle, taille, localisation
•	Vue organigramme : Hiérarchique interactif
•	Actions : Créer département, modifier structure, affecter manager
Écran détail département
Tabs:
├── 👥 Équipe & Effectifs
│   ├── Liste des employés
│   ├── Manager et responsables
│   ├── Répartition par poste
│   ├── Pyramide hiérarchique
│   └── Évolution effectifs
│
├── 📊 Indicateurs de performance
│   ├── Taux d'absentéisme
│   ├── Productivité moyenne
│   ├── Satisfaction équipe
│   ├── Turn-over département
│   └── Budget vs réalisé
│
├── 💰 Masse salariale
│   ├── Budget alloué
│   ├── Salaires totaux
│   ├── Primes et variables
│   ├── Charges sociales
│   └── Coût moyen par employé
│
└── 🎯 Objectifs & Projets
    ├── Objectifs trimestriels
    ├── Projets en cours
    ├── Ressources nécessaires
    └── Indicateurs de réussite
Organigramme interactif
•	Vue graphique avec zoom/déplacement
•	Export PDF/PNG
•	Édition drag & drop des rattachements
•	Visualisation chaîne hiérarchique
 
🔹 4. GESTION DES PRÉSENCES
Tableau de bord pointages
•	Vue journalière : Présents/Absents/Retards en temps réel
•	Calendrier mensuel : Visualisation présences par employé
•	Statistiques : Taux de présence, heures supplémentaires, retards
•	Anomalies : Pointages manquants, horaires incohérents
Écran pointage employé
•	Système de badgeage (scan carte/QR code)
•	Pointage manuel avec justification
•	Déclaration télétravail
•	Demande d'ajustement horaire
•	Export relevé d'heures mensuel
Gestion des horaires
Informations:
├── ⏰ Horaires contractuels
│   ├── Type contrat (35h, 39h, forfait jour)
│   ├── Horaires standards
│   ├── Jours de repos hebdomadaires
│   └── Modulation temps de travail
│
├── 📅 Planning personnalisé
│   ├── Horaires variables
│   ├── Équipes (matin/après-midi/nuit)
│   ├── Astreintes programmées
│   └── Jours télétravail autorisés
│
├── ⏱️ Compteurs temps
│   ├── Heures travaillées période
│   ├── Heures supplémentaires
│   ├── Récupérations acquises
│   ├── RTT disponibles
│   └── Compte épargne temps
│
└── 📊 Analyse présence
    ├── Taux de présence mensuel
    ├── Retards cumulés
    ├── Absences non justifiées
    └── Régularité horaires
Calcul automatique heures
•	Décompte heures normales/supplémentaires
•	Majoration HS selon législation (25%/50%)
•	Gestion repos compensateurs
•	Calcul automatique RTT
 
🔹 5. GESTION CONGÉS & ABSENCES
Tableau des demandes
•	Filtres : En attente/Validées/Refusées, par type, par période
•	Workflow : Demande → Validation N+1 → Validation RH → Confirmation
•	Calendrier : Vue globale absences prévues
•	Alertes : Chevauchements, effectif minimum non respecté
Formulaire demande de congé
•	Sélection type : CP, RTT, Congé sans solde, Événement familial
•	Calcul automatique solde restant
•	Vérification règles d'ancienneté
•	Suggestion dates selon planning équipe
•	Pièces justificatives si nécessaire
Écran gestion soldes
Compteurs employé:
├── 🏖️ Congés payés
│   ├── Acquis année N
│   ├── Report année N-1
│   ├── Pris à date
│   ├── Posés en attente
│   └── Solde disponible
│
├── ⏰ RTT
│   ├── Droits annuels
│   ├── Acquis mensuels
│   ├── Consommés
│   └── Restants
│
├── 🏥 Absences maladie
│   ├── Arrêts ordinaires (cumul)
│   ├── Arrêts longue durée
│   ├── Accidents de travail
│   └── Maladies professionnelles
│
└── 👶 Congés spéciaux
    ├── Maternité/Paternité
    ├── Événements familiaux
    ├── Formation professionnelle
    └── Congé sabbatique
Validation hiérarchique
•	Circuit validation configurable
•	Notifications automatiques demandeur/valideurs
•	Commentaires et motifs de refus
•	Historique décisions
 
🔹 6. GESTION RECRUTEMENT
Pipeline candidatures
•	Kanban board : CV reçus → Présélection → Entretien → Offre → Embauche
•	Filtres : Par poste, source candidature, statut
•	Actions : Planifier entretien, envoyer email, archiver
Écran poste à pourvoir
Fiche poste:
├── 📋 Description
│   ├── Intitulé poste
│   ├── Département de rattachement
│   ├── Missions principales
│   ├── Responsabilités
│   └── Liens hiérarchiques
│
├── 🎯 Profil recherché
│   ├── Formation requise
│   ├── Expérience minimum
│   ├── Compétences techniques
│   ├── Compétences comportementales
│   └── Langues exigées
│
├── 💼 Conditions
│   ├── Type contrat (CDI/CDD/Stage)
│   ├── Durée si CDD
│   ├── Fourchette salariale
│   ├── Avantages proposés
│   └── Date prise de poste
│
└── 📢 Diffusion
    ├── Sites d'emploi
    ├── Réseaux sociaux
    ├── Cooptation interne
    └── Cabinets de recrutement
Gestion candidatures
•	Import CV (parsing automatique données)
•	Scoring automatique selon critères
•	Historique échanges candidat
•	Planification entretiens avec disponibilités
•	Grille évaluation standardisée
•	Génération offre d'embauche
Onboarding nouveaux arrivants
•	Checklist intégration (badge, matériel, accès)
•	Parcours de formation initiale
•	Présentation équipe et locaux
•	Suivi période d'essai
•	Évaluation première période
 
🔹 7. FORMATIONS & DÉVELOPPEMENT
Plan de formation annuel
•	Budget global et par département
•	Formations obligatoires réglementaires
•	Formations métier et développement
•	Calendrier sessions prévues
•	Taux de réalisation vs objectifs
Catalogue formations
Types formations:
├── 🎓 Formations obligatoires
│   ├── Sécurité et prévention
│   ├── Habilitations techniques
│   ├── Conformité réglementaire
│   └── Formations métier légales
│
├── 💼 Formations métier
│   ├── Techniques professionnelles
│   ├── Logiciels et outils
│   ├── Processus internes
│   └── Nouveaux produits/services
│
├── 🚀 Développement personnel
│   ├── Management et leadership
│   ├── Communication
│   ├── Gestion du temps
│   └── Efficacité professionnelle
│
└── 🌍 Langues
    ├── Anglais professionnel
    ├── Autres langues
    ├── Niveaux débutant à expert
    └── Certifications (TOEIC, etc.)
Gestion session formation
•	Inscription employés
•	Convocations automatiques
•	Feuilles émargement électroniques
•	Évaluation à chaud/à froid
•	Attestations formation
•	Mise à jour compétences employé
Entretiens professionnels
•	Planification entretiens annuels
•	Grille d'entretien structurée
•	Bilan compétences acquises
•	Identification besoins formation
•	Définition objectifs N+1
•	Suivi plan de développement
 
🔹 8. ÉVALUATIONS & PERFORMANCE
Campagnes d'évaluation
•	Calendrier évaluations annuelles
•	Relances automatiques managers
•	Suivi taux de réalisation
•	Consolidation résultats
•	Analyse performance globale
Écran entretien individuel
Dossier évaluation:
├── 🎯 Bilan année écoulée
│   ├── Objectifs fixés
│   ├── Taux de réalisation
│   ├── Réalisations marquantes
│   ├── Difficultés rencontrées
│   └── Compétences mobilisées
│
├── 📊 Évaluation compétences
│   ├── Compétences techniques
│   ├── Compétences managériales
│   ├── Savoir-être professionnel
│   ├── Points forts
│   └── Axes d'amélioration
│
├── 🚀 Objectifs année N+1
│   ├── Objectifs quantitatifs
│   ├── Objectifs qualitatifs
│   ├── Projets assignés
│   ├── Indicateurs mesure
│   └── Moyens nécessaires
│
├── 🎓 Développement
│   ├── Besoins formation
│   ├── Compétences à acquérir
│   ├── Perspectives évolution
│   ├── Mobilité souhaitée
│   └── Accompagnement nécessaire
│
└── 💰 Rémunération
    ├── Discussion augmentation
    ├── Primes performance
    ├── Avantages supplémentaires
    └── Décisions prises
Gestion des objectifs
•	Définition objectifs SMART
•	Assignation aux employés
•	Suivi avancement temps réel
•	Ajustement en cours d'année
•	Évaluation atteinte objectifs
9-Box & Revue talents
•	Matrice performance/potentiel
•	Identification hauts potentiels
•	Plans de succession
•	Viviers leadership
•	Mobilité et promotions
 
🔹 9. PAIE & RÉMUNÉRATION
Traitement de la paie
•	Import variables paie (absences, HS, primes)
•	Calcul automatique cotisations sociales
•	Génération bulletins de paie
•	Virement bancaire automatique
•	Déclarations sociales (DSN)
Écran bulletin de paie
Éléments bulletin:
├── 💼 Identification
│   ├── Employeur (raison sociale, SIRET)
│   ├── Salarié (nom, matricule, poste)
│   ├── Période de paie
│   └── Numéro bulletin
│
├── ⏰ Temps de travail
│   ├── Heures contractuelles
│   ├── Heures réellement travaillées
│   ├── Heures supplémentaires
│   ├── Absences déduites
│   └── Congés payés pris
│
├── 💰 Rémunération brute
│   ├── Salaire de base
│   ├── Primes (ancienneté, performance, etc.)
│   ├── Avantages en nature
│   ├── Heures supplémentaires majorées
│   └── Total brut
│
├── 📉 Cotisations
│   ├── Cotisations salariales
│   │   ├── Sécurité sociale
│   │   ├── Retraite
│   │   ├── Chômage
│   │   └── CSG/CRDS
│   ├── Cotisations patronales
│   └── Total cotisations
│
└── 💵 Net à payer
    ├── Net imposable
    ├── Prélèvement à la source
    ├── Autres retenues
    └── NET À PAYER
Gestion éléments variables
•	Prime d'ancienneté automatique
•	Prime de performance selon évaluation
•	Prime de présentéisme
•	Indemnités transport
•	Tickets restaurant
•	Avantages en nature (véhicule, téléphone)
Historique rémunération
•	Évolution salaire dans le temps
•	Historique augmentations
•	Primes exceptionnelles
•	Comparaison marché (benchmark)
•	Analyse écarts salariaux
 
🔹 10. NOTES DE FRAIS
Tableau demandes de remboursement
•	Statut : En attente/Validées/Remboursées/Refusées
•	Montant total à rembourser
•	Délai moyen traitement
•	Rappels dépassements délais
Formulaire note de frais
•	Catégories : Déplacement, Repas, Hébergement, Fournitures
•	Scan justificatifs (tickets, factures)
•	Calcul automatique barème kilométrique
•	Contrôle plafonds et règles de gestion
•	Visa hiérarchique
•	Validation service comptable
Politique de remboursement
•	Barèmes par catégorie
•	Plafonds journaliers
•	Liste frais remboursables/non remboursables
•	Délais de soumission
•	Circuit de validation
 
🔹 11. DISCIPLINE & SANCTIONS
Registre disciplinaire
•	Avertissements et blâmes
•	Mises à pied
•	Sanctions graves
•	Respect procédure légale
•	Notification employé et représentants
Gestion incident
Dossier disciplinaire:
├── 📋 Description incident
│   ├── Date et heure
│   ├── Lieu
│   ├── Nature des faits
│   ├── Témoins éventuels
│   └── Pièces à l'appui
│
├── 👤 Employé concerné
│   ├── Identité complète
│   ├── Poste et ancienneté
│   ├── Antécédents disciplinaires
│   └── Circonstances atténuantes
│
├── ⚖️ Procédure
│   ├── Convocation entretien
│   ├── Date entretien préalable
│   ├── Présence représentant
│   ├── Explications employé
│   └── Délai de réflexion
│
└── 📄 Décision
    ├── Type de sanction
    ├── Motifs détaillés
    ├── Notification écrite
    ├── Voies de recours
    └── Archivage légal
Traçabilité légale
•	Respect délais légaux
•	Archivage sécurisé
•	Consultation IRP si nécessaire
•	Historique actions correctives
 
🔹 12. ACCIDENTS & MÉDECINE DU TRAVAIL
Déclaration accidents de travail
•	Formulaire AT/MP
•	Déclaration CPAM dans délais
•	Suivi arrêt de travail
•	Reprise après AT
•	Analyse causes et prévention
Suivi médical
Dossier santé:
├── 🏥 Visites médicales
│   ├── Visite d'embauche
│   ├── Visites périodiques
│   ├── Visites de reprise
│   ├── Visites à la demande
│   └── Prochaine visite due
│
├── 💉 Vaccinations
│   ├── Obligatoires selon poste
│   ├── Recommandées
│   ├── Dates et rappels
│   └── Certificats médicaux
│
├── 🛡️ Aptitude au poste
│   ├── Avis médecin du travail
│   ├── Restrictions éventuelles
│   ├── Aménagements nécessaires
│   ├── Inaptitude temporaire/définitive
│   └── Reclassement si nécessaire
│
└── 📊 Statistiques santé
    ├── Taux d'accidents
    ├── Maladies professionnelles
    ├── Journées perdues
    └── Actions prévention
Prévention des risques
•	Document unique évaluation risques (DUER)
•	Formation sécurité obligatoire
•	EPI fournis et renouvelés
•	Visites poste de travail
•	Registres réglementaires
 
🔹 13. COMPTABILITÉ RH
Masse salariale
•	Budget prévisionnel vs réalisé
•	Coût total employeur (brut + charges)
•	Répartition par département
•	Évolution mensuelle et annuelle
•	Projections embauches/départs
Provisions et charges
Analyse financière RH:
├── 💰 Charges de personnel
│   ├── Salaires bruts
│   ├── Charges sociales patronales
│   ├── Primes et bonus
│   ├── Avantages sociaux
│   └── Formations
│
├── 📊 Provisions
│   ├── Congés payés non pris
│   ├── CET (Compte Épargne Temps)
│   ├── Primes variables à verser
│   ├── Indemnités départ retraite
│   └── Litiges prud'homaux
│
├── 🎯 Budget vs Réalisé
│   ├── Par département
│   ├── Par nature de dépense
│   ├── Écarts et analyses
│   └── Ajustements nécessaires
│
└── 📈 Ratios financiers
    ├── Masse salariale / CA
    ├── Coût moyen par employé
    ├── Productivité par tête
    └── ROI formations
Déclarations sociales
•	DSN mensuelle automatisée
•	Déclarations trimestrielles
•	Déclarations annuelles (DADS)
•	Taxe d'apprentissage
•	Participation formation continue
 
🔹 14. REPORTING & STATISTIQUES RH
Tableau de bord direction
Widgets analytics:
├── 👥 Indicateurs effectifs
│   ├── Effectif total (ETP)
│   ├── Répartition CDI/CDD/Stages
│   ├── Ancienneté moyenne
│   ├── Pyramide des âges
│   └── Ratio hommes/femmes
│
├── 📊 Indicateurs sociaux
│   ├── Taux d'absentéisme
│   ├── Turn-over (démissions/licenciements)
│   ├── Mobilité interne
│   ├── Promotions accordées
│   └── Accidents de travail
│
├── 🎓 Formation & Développement
│   ├── Heures formation par employé
│   ├── Budget formation consommé
│   ├── Taux accès formation
│   ├── Évaluations à jour
│   └── Compétences critiques manquantes
│
├── 💰 Indicateurs paie
│   ├── Masse salariale totale
│   ├── Salaire moyen/médian
│   ├── Écarts salariaux H/F
│   ├── Évolution charges sociales
│   └── Primes distribuées
│
└── 📈 Tendances & Prévisions
    ├── Évolution effectifs 12 mois
    ├── Prévisions départs retraite
    ├── Besoins recrutement
    └── Risques sociaux identifiés
Rapports réglementaires
•	Bilan social annuel
•	Index égalité professionnelle
•	Rapport formation professionnelle
•	BDES (Base de Données Économiques et Sociales)
•	Registres obligatoires
Rapports personnalisables
•	Générateur requêtes visuelles
•	Templates : Effectifs, Absentéisme, Paie, Formation
•	Planification envois automatiques
•	Exports : PDF, Excel, CSV
 
🔹 15. PARAMÈTRES & ADMINISTRATION
Configuration entreprise
•	Informations société (SIRET, convention collective)
•	Structure organisationnelle
•	Grilles salariales et classifications
•	Barèmes primes et indemnités
•	Templates documents RH
Gestion utilisateurs & sécurité
Profils d'accès:
├── 👑 Administrateur RH
│   └── Accès total système
│
├── 👔 Directeur RH
│   ├── Tous modules RH
│   ├── Validation budgets
│   ├── Reporting direction
│   └── Décisions stratégiques
│
├── 👨‍💼 Responsable RH
│   ├── Gestion employés
│   ├── Recrutement
│   ├── Formation
│   └── Discipline
│
├── 💰 Gestionnaire paie
│   ├── Éléments variables
│   ├── Bulletins de paie
│   ├── Déclarations sociales
│   └── Charges sociales
│
├── 👥 Manager
│   ├── Équipe sous responsabilité
│   ├── Validation congés
│   ├── Évaluations équipe
│   └── Demandes recrutement
│
└── 👤 Employé
    ├── Profil personnel
    ├── Bulletins de paie
    ├── Demandes congés
    ├── Notes de frais
    └── Formations disponibles
Conformité & Audit
•	Logs toutes actions horodatées
•	Historique modifications données sensibles
•	Sauvegarde automatique quotidienne
•	Conformité RGPD (consentements, droit accès/rectification/oubli)
•	Archivage légal documents (5 ans minimum)
 
🖥️ Maquettes Application SIRH
1️⃣ Écran Dashboard RH
-------------------------------------------------------------------
| Menu Latéral     | Tableau de Bord RH                            |
| (Sidebar)        |----------------------------------------------|
|                  | [Carte] Effectif total : 247 employés       |
| 📊 Dashboard     | [Carte] Présents aujourd'hui : 232 (94%)    |
| 👥 Employés      | [Carte] En cong

