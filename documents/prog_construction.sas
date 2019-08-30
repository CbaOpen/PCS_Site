


/********************************************************************************/
/* 						Programme d'implémentation du							*/
/*	  			  schéma de classes et sous-classes d'emploi					*/
/*																				*/
/*								Et macros d'analyse								*/
/*						 permettant de les comparer avec						*/
/*						           les GS/CS									*/
/*																				*/
/*							T. Amossé, 19 juin 2018 							*/
/********************************************************************************/





/* L ensemble des noms qui sont à adapter pour une reprise du programme avec vos sources sont :
- SOURCE ;
- TABLE ;
- la variable de poids (ici EXTRID) ;
- les variables de PCS (P, CSTOT, CSTOTI, GSTOT) ;
- la variable d'ISCO (PEUN) ;
- les variables d'activité BIT pour le champ : ACTEU ;
- les variables déclaratives servant à coder les agrégats : STNRED CHPUB CONTRA NBSALB ;
- les variables à analyser (ici comme premiers exemples : SEXE AGE DDIPL SO) ;

Des ajouts et adaptations des macros sont par ailleurs possibles pour des comparaisons avec EseG.
*/



/* déclaration des librairies */
libname SOURCE "F:\Bégonia\Mes documents\Refonte PCS, GT Cnis 2017-\Sous-groupe 3\Ménage\Données\lil-1262b.sas7bdat\SAS";
* "libraire de la source utilisée" ;



/* création de la table */
data SOURCE.TABLE ; 
set SOURCE.indiv171 SOURCE.indiv172 SOURCE.indiv173 SOURCE.indiv174;
run;



/* Définition des variables servant à créer l'agrégat à partir des variables déclaratives de l'enquête Emploi. Les noms
des variables équivalentes dans les sources utilisées pour les tests doivent évidemment remplacer les noms ci-dessous.
A priori, on testerait sur le champ des personnes en emploi. Il s'agit d'un premier modèle, qui peut être adapté aux 
professions antérieures (chômeurs, inactifs ayant déjà travaillé), quand les variables déclaratives sont posées. Par 
ailleurs, certaines adaptations sont nécessaires quand on ne dispose pas exactement de */
data TABLE ;
set SOURCE.TABLE;
keep 	RGA /* rang d'interrogation de l'aire : utilisée ici pour limiter les statistiques aux premières interrogations
		(pas de biais d'attrition ou de rotation) ; spécifique à l'enquête Emploi */ 
		EXTRID /* variable de poids à utiliser avec la restriction à l'aire entrante */

		P CSTOT CSTOTI GSTOT /* variables de PCS de l'enquête emploi : CSTOTI en 17 postes sur les actifs occupés */
		PEUN /* variable d'ISCO */
		ACTEU CHAMP_EMPLOI /* variable d'activité BIT et de champ réduit aux personnes en emploi BIT, à utiliser */

		STC /* variable déclarative de statut salarié - non salarié, avec les salariés chefs d'entreprise
		comptés du côté des non salariés ; non redressée pour être cohérente avec la profession */ 
		CHPUB /* variable déclarative correspond à la nature publique / privée de l'employeur */
		CONTRA /* variable déclarative de type de contrat pour tous les salariés (hors fonctionnaires) */ TITC
		NBSALA NBSALB /* variables déclaratives de nombre de salariés dans l'entreprise (utilisée pour les indépendants) */
		/* variables créées à partir des variables déclaratives ci-dessus */
		INDEPENDANT NB10 PRECAIRE PUBLIC POSITION DOMAINE

		/* exemples de variables à analyser en croisement */
		SEXE AGE 

		DDIPL SO;

EXTRID=EXTRID/4; /* poids pour les variables posées seulement en vague entrante */

GSTOT = substr(CSTOT,1,1); /* niveau agrégé des GS */

CHAMP_EMPLOI = (ACTEU = "1") and (GSTOT not in (" ","0")); /* champ d'emploi au sens du BIT et CSTOT connue */

/* champ limité aux personnes en emploi BIT, donc ; à terme, l'extension aux chômeurs et inactifs suppose que l'on puisse
avoir la variable pour tout le monde (à partir de l'EEC 2021 ?). Voir pour des extensions avant ? */
if CHAMP_EMPLOI = 1 ;

/* uniquement déclaratif */
INDEPENDANT = (STC in ("1","2","4"," ")); /* statut déclaratif non salarié ou non renseigné, les valeurs manquantes
correspondent à des statuts non déclarés, par exemple pour les activités informelles, dont on ne présuppose pas qu'il
s'agit de contrat salarié (différence avec la règle de droit) */

/* uniquement déclaratif, que pour les indépendants, en distinguant les travailleurs dans des entreprises mono- et multi-
établissements */
NB10 = .;
if INDEPENDANT and NBSALB not in ("13") then do;
	if NBSALB in ("10","11","12") then NB10 = 10; /* 10 salariés et plus */
	else if NBSALB in ("1","2","3","4","5","6","7","8","9") then NB10 = 1; /* de 1 à 9 salariés */
	else NB10 = 0; /* 0 salariés et nombre de salariés inconnu */
end;
else if INDEPENDANT then do;
	if NBSALA in ("10","11","12") then NB10 = 10; /* 10 salariés et plus */
	else if NBSALA in ("1","2","3","4","5","6","7","8","9") then NB10 = 1; /* de 1 à 9 salariés */
	else NB10 = 0; /* 0 salariés et nombre de salariés inconnu */
end;

/* uniquement déclaratif : on met tous les types de contrats sauf les CDI, donc les sans contrats, les CDD, l'intérim,
les contrats saisonniers, l'apprentissage. Sachant que les fonctionnaires titulaires sont du côté des valeurs manquantes
sur cette variable. Vérifier que les valeurs manquantes ne sont pas */
PRECAIRE = .;
if not INDEPENDANT then PRECAIRE = (CONTRA in ("0","2","3","4","5"));

/* uniquement déclaratif : on met les 3 FP (E,T,H) mais pas la Sécurité sociale (on n'aura pas cette précision avec 
la variable multi-mode proposée à terme). */
PUBLIC = .;
if not INDEPENDANT and not PRECAIRE then PUBLIC = (CHPUB in ("3","4","5"));

/* on prend comme indicateur de qualification le groupe socio-professionnel avec les ajustements prévus entre A et B, B et C, 
C et D. Il faut la P 2003 (à terme 2020) pour cela. */

/* POSITION, niveau de qualification pour les salariés, mais qui est quand même défini pour les P-CS-GS d'indépendant
au cas où il y aurait des incohérences de statut. Donc cela doit correspondre exactement à la définition A*-B*-C*-D* */ 
POSITION = .;
		if (CSTOT in ("23") or GSTOT in ("1","2") and NB10 in (10)) /* a priori vide sur les salariés */ 
		or (GSTOT = "3" and P not in ("313a","354b","354c","354d","354g")) /* sont exclus les artistes du spectacle vivant
		et les professeurs (non scolaires) des disciplines artistiques */ 
        or P in ("421a","421b","422a","422b","422c","422d") /* tous les enseignants et les CPE */
        or P in ("431a","431e","434a","435a") /* les sages femmes, cadres du soin infirmier et de travail social (les autres 
		infirmières spécialisées, notamment de bloc, ne sont pas intégrées car elles sont fusionnées en P 2020)... Par contre
		les cadres de l'animation socio-culturelle, qui sont fusionnés en P 2020 avec ceux du travail social, sont intégrés. */
        or P in ("451d","452a") /* les officiers de la police nationale et les ingénieurs du contrôle aérien (les traducteurs
		et interprètes ne sont pas montés en A, car ils sont fusionnés en P 2020 avec des P qui restent en B). */
 		then POSITION = 4; 
		else if P in ("214e") or substr(P,1,3) in ("225","226","227") /* artisans d'art et intermédiaires du commerce,
		des assurances, voyage, immobiliers et prestataires de services. Attention, en P 2003, risque de divergence
		entre le classement des moniteurs d'auto-école selon leur statut (en I2 et C). Amènerait à les laisser en B ? */ 
		or GSTOT in ("3") /* on récupère les professions du groupe 3 exclues ci-dessus */
		or (GSTOT in ("4") and P not in ("422e","423a","433d","435b")) /* sont exclus les surveillants scolaires, 
		les moniteurs d'auto-école, les animateurs socio-culturels, les préparateurs en pharmacie */
		or P in ("531a","532a","533a","533b") /* policiers nationaux et agents pénitentiaires équivalents, gendarmes, 
		sous-officiers subalternes de l'armée, pompiers */ 
		or P in ("545a","545b","545c","545d") /* employés commerciaux et technique de la banque, des assurances et de la
		sécurité sociale */ 
		or P in ("546a","546d","546e") /* stewards, hotesses, contrôleurs de train et autres accompagnants des transports,
		le dernier par fusion en P 2020 */
		/* on ne prend pas les employés de la bureautique et de l'informatique, car ils sont fusionnés en P , avec les 
		secrétaires, qui restent en C. */
		or P in ("637b","637c") /* ouvriers d'art et des spectacles, les premiers par fusion en P 2020. */ 
		or P in ("654a","656a") /* les conducteurs de train et matelots, les seconds par fusion en P 2020. */
		/* on n'intègre pas les dockers, car ils sont fusionnés en P 2020 avec les conducteurs d'engin, qui sont nombreux
		et moins qualifiés */ 
        then POSITION = 3;
		else if (GSTOT in ("1","2") and NB10 in (10,1)) /* a priori vide, surtout avec la clause NB10, qui est toujours à vide :
		clause de taille à lever à terme ? Quitte à mettre ces éventuels salariés déclaratifs classés indépendants en 
		qualifiés par défaut */
		or GSTOT = "4" /* on récupère les professions du groupe 4 exclues ci-dessus */
		or (GSTOT in ("5") and P not in ("525a","525b","525c","525d","533c","534a","534b","541d","542b",
			"551a","552a","553a","554a","554h","554j","555a","561a","561d","561e","561f","563a","563b","563c","564a",
			"564b"))
		/* on garde la définition d'Olivier, qui est robuste, en intégrant simplement les contraintes liées à des fusions
		en P 2020 (534b,). Attention, pour les vendeurs de gros sont exclus en P 2003 et peut-être partiellement inclus
		en P 2020, n'étant plus distingués. Une question quand même sur la pertinence de mettre en D le 564b, qui apparaît
		assez qualifié, avec les employés de casino, sacristains et agents des pompes funèbres, etc. */ 
		or (CSTOT in ("62","63","64","65") and P not in ("642a","642b","643a","652a","653a")) 
		/* sont exclus, donc en D, les taxis, VTC, coursiers et livreurs, magasiniers et caristes */
		/* on garde sinon les délimitations liées à la CS, y compris en 69, qui est hétérogène mais y compris au niveau
		des P, qui sont structurées par métiers */ 
		then POSITION= 2;
		else if (GSTOT in ("1","2") and NB10 in (0,.)) /* a priori vide, surtout avec la clause NB10, qui est toujours à 
		vide : clause de taille à lever à terme ? Quitte à mettre ces éventuels salariés déclaratifs classés indépendants 
		en qualifiés par défaut */
		or GSTOT in ("5","6") 
		then POSITION= 1; 

/* DOMAINE */
DOMAINE = .; /* domaine marginalement affecté pour les PCS d'indépendants : les 23 de moyenne ou grande entreprise sont
en administratif, car on suppose qu'ils ou elles font surtout du travail commercial ou gestionnaire ; les professions 
libérales techniques sont identifiées */
if not INDEPENDANT and not PUBLIC and not PRECAIRE then do;
	if P in ("233a","233b","312e","312f","312g") or CSTOT in ("11","12","13","21","38","47","48") or GSTOT = "6" then 
	DOMAINE = 1;
	else if CSTOT in ("22","23","31","33","34","35","37","42","43","44","45","46") or GSTOT = "5" then DOMAINE = 2;
end;

run;



/* Construction des agrégats dans leurs différentes versions */
data TABLE;
set TABLE;

/* C_SC : schéma de classes et sous-classes. */ 
C_SC = "  ";

if INDEPENDANT = 1 then do;
 if POSITION = 4 then C_SC = "I1";
 else if POSITION = 3 then C_SC = "I2";
 else if POSITION = 2 then C_SC = "I3";
 else if POSITION = 1 then C_SC = "I4";
end;
else if INDEPENDANT = 0 then do;
 if POSITION = 4 then do;
 	if PRECAIRE = 1 then C_SC = "A4";
	else if PRECAIRE = 0 and PUBLIC = 1 then C_SC = "A3";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 2 then C_SC = "A2";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 1 then C_SC = "A1";
  end;
 else if POSITION = 3 then do;
 	if PRECAIRE = 1 then C_SC = "B4";
	else if PRECAIRE = 0 and PUBLIC = 1 then C_SC = "B3";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 2 then C_SC = "B2";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 1 then C_SC = "B1";
  end;
else if POSITION = 2 then do;
 	if PRECAIRE = 1 then C_SC = "C4";
	else if PRECAIRE = 0 and PUBLIC = 1 then C_SC = "C3";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 2 then C_SC = "C2";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 1 then C_SC = "C1";
  end;
else if POSITION = 1 then do;
 	if PRECAIRE = 1 or substr(P,1,3) in ("563") then C_SC = "D4"; /* on ajoute les professions des services à la personne.
	Il faut avoir conscience que cela introduit un peu de public ici... */
	else if PRECAIRE = 0 and PUBLIC = 1 then C_SC = "D3";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 2 then C_SC = "D2";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 1 then C_SC = "D1";
  end;
end;

/* définition des agrégats au niveau agrégé : G_ en préfixe, pour groupe */
G_C = substr(C_SC,1,1) ;

/* version alternative en reclassant les I. dans A,B,C et D */
G_C_ = G_C;
if C_SC = "I1" then G_C_ = "A";
else if C_SC = "I2" then G_C_ = "B";
else if C_SC = "I3" then G_C_ = "C";
else if C_SC = "I4" then G_C_ = "D";

run;

/* Avec ce programme, on dispose d'une variable de classes et sous-classes, C_SC, avec le niveau agrégé classique en 5
classes G_C et stratifié en 4 classes G_C_. */

/* vérification de la construction : la structure est bien équilibrée, 12% chez les indépendants et sinon 18%-22%-24%-23%
et en quatre classes : 21%-25%-26%-28% */ 
proc freq data = TABLE ;
tables C_SC G_C G_C_ /missing;
weight EXTRID;
where RGA = "1";
run;
/* Cela fonctionne sur les variables construites en amont, comme attendu ! Cela fonctionne bien pour les précaires et
le public (on n'a que les contractuels à durée limitée en précaire). Cela fonctionne aussi pour le nombre de salariés :
seul NBSALB est renseigné pour les indépendants ; et les cas non renseignés en " " et "13" sont en 0. */
proc freq data = TABLE ;
tables INDEPENDANT * PRECAIRE * PUBLIC * CONTRA * TITC /list missing;
weight EXTRID;
where RGA = "1";
run;
proc freq data = TABLE ;
tables INDEPENDANT * NB10 * NBSALA * NBSALB /list missing;
weight EXTRID;
where RGA = "1";
run;
/* cela fonctionne comme attendu ! */
proc freq data = TABLE ;
tables C_SC * (POSITION INDEPENDANT PUBLIC PRECAIRE DOMAINE) /list missing;
weight EXTRID;
where RGA = "1";
run;
/* cela a l'air de fonctionner comme attendu, à vérifier plus précisément toutefois ! */
proc freq data = TABLE ;
tables G_C * (GSTOT CSTOT P) /list missing;
weight EXTRID;
where RGA = "1";
run;
proc freq data = TABLE ;
tables G_C_ * (GSTOT CSTOT P) /list missing;
weight EXTRID;
where RGA = "1";
run;
proc freq data = TABLE ;
tables C_SC * (GSTOT CSTOT P) /list missing;
weight EXTRID;
where RGA = "1";
run;





/* Exemples de construction d'indicateurs et de redéfinition de l'ensemble des agrégats existants pour les comparaisons */
data TABLE;
set TABLE;

/* exclusion des vagues non entrantes : clause facultative, mais suppose alors de revoir les poids dans l'enquête
Emploi */
if RGA = "1";

/* construction d'indicateur à partir d'une variable qualitative */
FEMME = (SEXE = "2");

/* construction d'indicateur à partir d'une variable quantitative */
AGE_30 = (. < AGE < 30);

/* construction d'une variable qualitative à partir d'une variable quantitative */
AGE_D = int(AGE/10);
if AGE_D in (1,2) then AGE_D = 2; /* on tronque à moins de 30 ans */
if AGE_D in (5,6,7,8) then AGE_D = 5; /* on tronque à 50 ans et plus */

/* création d'une variable supplémentaire de HLM */
HLM = (SO in ("3")); 

/* création de versions alternatives des catégories et groupe à comparer */

/* GSTOT_ en 5 postes, avec une agrégation des agriculteurs et des artisans commerçants et chefs d'entreprise */
GSTOT_ = GSTOT;
if GSTOT = "1" then GSTOT_ = "2";

/* définition d'ISCO 1 et 2 */
ISCO1 = substr(PEUN,1,1);
ISCO2 = substr(PEUN,1,2);

/* implémentation d'EseG 1/2 */

/* niveau agrégé */
ESeG1 = " ";
if ISCO1="1" or (ISCO2="01" and not INDEPENDANT) then ESeG1="1" ;
if ISCO1="2" then ESeG1="2" ;
if (ISCO1="3" and not INDEPENDANT) or (ISCO2="02" and not INDEPENDANT) then ESeG1="3" ;
if ISCO1 in ("3", "4", "5", "6", "7", "8", "9") and INDEPENDANT then ESeG1="4" ;
if (ISCO1="4" or ISCO2 in ("03", "53", "54")) and not INDEPENDANT then ESeG1="5" ;
if ISCO1 in ("7", "8") and not INDEPENDANT  then ESeG1="6" ;
if (ISCO1 in ("6", "9") or ISCO2 in ("51", "52")) and not INDEPENDANT then ESeG1="7" ;

/* niveau détaillé */
if ISCO2 in ("11","12","13") and INDEPENDANT then ESeG2 = "11" ;
if ISCO2 = "14" and INDEPENDANT then ESeG2 = "12" ;
if ISCO2 in ("01","11","12","13") and not INDEPENDANT then ESeG2 = "13" ;
if ISCO2 = "14" and not INDEPENDANT then ESeG2 = "14" ;
if ISCO2 in ("21","25") then ESeG2 = "21" ;
if ISCO2 = "22" then ESeG2 = "22" ;
if ISCO2 = "24" then ESeG2 = "23" ;
if ISCO2 = "26" then ESeG2 = "24" ;
if ISCO2 = "23" then ESeG2 = "25" ;
if ISCO2 in ("31","35") and not INDEPENDANT then ESeG2 = "31" ;
if ISCO2 = "32" and not INDEPENDANT then ESeG2 = "32" ;
if ISCO2 = "33" and not INDEPENDANT then ESeG2 = "33" ;
if ISCO2 = "34" and not INDEPENDANT then ESeG2 = "34" ;
if ISCO2 = "02" and not INDEPENDANT then ESeG2 = "35" ;
if ISCO1 = "6" and INDEPENDANT then ESeG2 = "41" ;
if ISCO1 in ("3","4","5") and INDEPENDANT then ESeG2 = "42" ;
if ISCO1 in ("7","8","9") and INDEPENDANT then ESeG2 = "43" ;
if ISCO2 in ("41","43","44") and not INDEPENDANT then ESeG2 = "51" ;
if ISCO2 = "42" and not INDEPENDANT then ESeG2 = "52" ;
if ISCO2 = "53" and not INDEPENDANT then ESeG2 = "53" ;
if ISCO2 in ("03","54") and not INDEPENDANT then ESeG2 = "54" ;
if ISCO2 = "71" and not INDEPENDANT then ESeG2 = "61" ;
if ISCO2 = "75" and not INDEPENDANT then ESeG2 = "62" ;
if ISCO2 in ("72","73","74") and not INDEPENDANT then ESeG2 = "63" ;
if ISCO2 in ("81","82") and not INDEPENDANT then ESeG2 = "64" ;
if ISCO2 = "83" and not INDEPENDANT then ESeG2 = "65" ;
if ISCO2 in ("51","52") and not INDEPENDANT then ESeG2 = "71" ;
if ISCO2 in ("92","93","94","96") and not INDEPENDANT then ESeG2 = "72" ;
if ISCO2 in ("91","95") and not INDEPENDANT then ESeG2 = "73" ;
if ISCO1 = "6" and not INDEPENDANT then ESeG2 = "74" ;

run;



/* Constructions macros de comparaison avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro de description d'un indicateur quantitatif pour une grille donnée : moyenne pour chaque catégorie, dans l'ordre 
des catégories, puis triés par ordre croissant ; construction et impression d'indicateurs de dispersion */
%macro moyenne (V=FEMME,W=G_C);
proc means data = TABLE missing noprint;
var &V;
class &W ;
output out = sortie;
ways 1;
weight EXTRID;
where &W not in ("  ");
run;
data sortie_;
set sortie;
if _STAT_ = "MEAN";
MEAN = &V ;
drop _STAT_;
run;
proc sort data = sortie_;
by &W;
run;
data sortie__;
set sortie;
if _STAT_ = "SUMWGT";
SUMWGT = &V ;
drop _STAT_;
run;
proc sort data = sortie__;
by &W;
run;
data sortie___;
merge sortie_(in=in1) sortie__(in=in2);
by &W;
if in1 and in2;
run;
proc print data = sortie___ ;
var &W MEAN;
title "&V par &W";
run;
proc sort data = sortie___;
by MEAN;
run;
proc print data = sortie___ ;
var &W MEAN;
title "&V par &W";
run;
proc univariate data = sortie___ noprint ;
var MEAN;
weight SUMWGT;
title "&V par &W";
output out = sortie 
MEAN = MOYENNE RANGE = INTERVALLE QRANGE = INTERQUARTILE GINI = GINI;
run;
data sortie_&V._&W.;
set sortie;
V="                               ";
W="                               ";
V = "&V";
W = "&W";
CIR = INTERQUARTILE / MOYENNE; /* on privilégie la moyenne, bien que cela ne soit pas usuel, car elle ne dépend pas de la 
catégorisation, contrairement à la médiane */
ETR = INTERVALLE / MOYENNE;
run;
data resultat;
set resultat sortie_&V._&W.;
run;
%mend moyenne;



/* Constructions macros de comparaison des prototypes _D (définis dans les sources avec la P : "_D" remplacer systématiquement
par "_A" quand vous utilisez des sources où seules les CS existent) avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro qui compare, pour un indicateur, les différentes catégorisations agrégées V1-2 / A-D et GSTOT, GSTOT_ et ISCO1 
et ESeG1 */
%macro boucle_moyenne_G(V=FEMME);
data resultat ;
set _null_;
run;
%moyenne(V=&V,W=G_C);
%moyenne(V=&V,W=G_C_);
%moyenne(V=&V,W=GSTOT_);
%moyenne(V=&V,W=GSTOT);
%moyenne(V=&V,W=ISCO1); /* cette ligne peut être supprimée en fonction des variables disponibles dans vos sources */
%moyenne(V=&V,W=ESeG1); /* cette ligne peut être supprimée en fonction des variables disponibles dans vos sources */
proc print data = resultat;
var V W MOYENNE ETR CIR GINI;
title "&V G";
run;
%mend boucle_moyenne_G;



/* Constructions macros de comparaison des prototypes _D (définis dans les sources avec la P : "_D" remplacer systématiquement
par "_A" quand vous utilisez des sources où seules les CS existent) avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro qui compare, pour un indicateur, les différentes catégorisations détaillées V1-2 / A-D et CSTOTI et ISCO2 */
%macro boucle_moyenne_SG(V=FEMME);
data resultat ;
set _null_;
run;
%moyenne(V=&V,W=C_SC);
%moyenne(V=&V,W=CSTOTI);
%moyenne(V=&V,W=EseG2); /* cette ligne peut être supprimée en fonction des variables disponibles dans vos sources */
%moyenne(V=&V,W=ISCO2); /* cette ligne peut être supprimée en fonction des variables disponibles dans vos sources */
proc print data = resultat;
var V W MOYENNE ETR CIR GINI;
title "&V G";
run;
%mend boucle_moyenne_SG;



/* Constructions macros de comparaison des prototypes avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro de comparaison pour l'ensemble d'une variable qualitative */
%macro croisement(V=SEXE,W=G_C);
proc freq data = TABLE ;
tables &W * &V /nocol nofreq nopercent;
weight EXTRID;
title "&V par &W";
run;
proc freq data = TABLE noprint;
tables &V * &W /CHISQ;
weight EXTRID;
output out = sortie_&V._&W. CHISQ;
run;
data sortie_&V._&W.;
set sortie_&V._&W.;
V="                               ";
W="                               ";
V = "&V";
W = "&W";
keep V W _PHI_ _CONTGY_ _CRAMV_ ;
run;
data resultat;
set resultat sortie_&V._&W.;
run;
%mend croisement;
%macro boucle_croisement(V=SEXE);
data resultat ;
set _null_;
run;
%croisement(V=&V,W=G_C);
%croisement(V=&V,W=G_C_);
%croisement(V=&V,W=GSTOT);
%croisement(V=&V,W=GSTOT_);
%croisement(V=&V,W=ISCO1);
%croisement(V=&V,W=ESeG1);
%croisement(V=&V,W=C_SC);
%croisement(V=&V,W=CSTOTI);
%croisement(V=&V,W=ISCO2);
%croisement(V=&V,W=ESeG2);
proc print data = resultat;
var V W _PHI_ _CONTGY_ _CRAMV_ ;
run;
title "&V";
%mend boucle_croisement;



/* Constructions macros de comparaison des prototypes avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro de comparaison pour une variable quantitative : par exemple l'âge (le revenu, après transformation lognormale ; 
etc.) */
/* le calcul du R² ajusté est inclus pour permettre l'ajout de variables de contrôle dans la régression, même si je ne
pense pas qu'elle soit utile */
%macro GLM(V=AGE,W=G_C);
proc glm data = TABLE ;
class &W ;
model &V = &W ; /* éventuel ajout de variables de contrôle à droite de &W */
title "&V par &W";
weight EXTRID; /* prise en compte des poids qui peut être discuté, donc la clause peut être supprimée */ 
ods output fitstatistics=STATISTIQUE_&V._&W.(keep=dependent rsquare) /*création de la table STATISTIQUE */
    overallanova=ANOVA_&V._&W.(where=(source='Model')) /* création de la table ANOVA */
    nobs=NOBS_&V._&W.(keep=nvalue1); /* création de la table NOBS */
run;
data rsq_&V._&W.;
 merge STATISTIQUE_&V._&W. ANOVA_&V._&W. NOBS_&V._&W.;
 m=df+1;
 adj_rsq=1-(1-rsquare)*((nvalue1-1)/(nvalue1-m)); /* calcul du R2 ajusté */
 keep rsquare adj_rsq W V;
 V = "                             ";
 W = "                             ";
 V = dependent ;
 W = "&W";
 if dependent = "&V";
run;
data resultat;
set resultat rsq_&V._&W.;
run;
%mend GLM;
%macro boucle_GLM(V=SEXE);
data resultat;
set _null_;
run;
%GLM(V=&V,W=G_C);
%GLM(V=&V,W=G_C_);
%GLM(V=&V,W=GSTOT);
%GLM(V=&V,W=GSTOT_);
%GLM(V=&V,W=ISCO1);
%GLM(V=&V,W=ESeG1);
%GLM(V=&V,W=C_CS);
%GLM(V=&V,W=CSTOTI);
%GLM(V=&V,W=ISCO2);
%GLM(V=&V,W=ESeG2);
quit;
proc print data = resultat;
title "&V";
run;
%mend boucle_GLM;



/* Exemples d'utilisation sur les deux exemples de variable de sexe et d'âge */
/* description des taux de femmes et de moins de 30 ans en comparant les catégorisations au niveau agrégé (G_SJ_V1 et 
G_SJ_V2 (ici définis dans une source il y a la P), GS et GS_ (avec 1 et 2 fusionnés), ISCO1, ESeG1) */
%boucle_moyenne_G(V=FEMME);
%boucle_moyenne_G(V=AGE_30);
/* description des taux de femmes et de moins de 30 ans en comparant les catégorisations au niveau détaillé (SJ_V1 et SJ_V2 
(ici définis dans une source il y a la P), CS, ISCO2, ESeG2) */
%boucle_moyenne_SG(V=FEMME);
%boucle_moyenne_SG(V=AGE_30);
/* description de l'association de l'ensemble des catégorisations (niveau agrégé et détaillé) avec les variables de sexe 
et d'âge décennal tronqué */
%boucle_croisement(V=SEXE);
%boucle_croisement(V=AGE_D);
/* description de l'association de l'ensemble des catégorisations (niveau agrégé et détaillé) avec la variable continue
d'âge */
%boucle_GLM(V=AGE_D);



/* il reste à voir si des statistiques peuvent être produites, qui permettent de comparer le degré d'association indépendemment
du nombre de classes, et si cela a un sens... En tous cas, avec les analyses ci-dessus, on a des éléments pour se faire 
une première idée de la distribution des indicateurs sur les différentes catégorisations. */  

/* le pouvoir explicatif sur le diplôme */
%boucle_croisement(V=DDIPL);
/* vivre en HLM */
%boucle_moyenne_G(V=HLM);
%boucle_moyenne_SG(V=HLM);
%boucle_croisement(V=SO);
