


/********************************************************************************/
/* 						Programme d'impl�mentation du							*/
/*	  			  sch�ma de classes et sous-classes d'emploi					*/
/*																				*/
/*								Et macros d'analyse								*/
/*						 permettant de les comparer avec						*/
/*						           les GS/CS									*/
/*																				*/
/*							T. Amoss�, 19 juin 2018 							*/
/********************************************************************************/





/* L ensemble des noms qui sont � adapter pour une reprise du programme avec vos sources sont :
- SOURCE ;
- TABLE ;
- la variable de poids (ici EXTRID) ;
- les variables de PCS (P, CSTOT, CSTOTI, GSTOT) ;
- la variable d'ISCO (PEUN) ;
- les variables d'activit� BIT pour le champ : ACTEU ;
- les variables d�claratives servant � coder les agr�gats : STNRED CHPUB CONTRA NBSALB ;
- les variables � analyser (ici comme premiers exemples : SEXE AGE DDIPL SO) ;

Des ajouts et adaptations des macros sont par ailleurs possibles pour des comparaisons avec EseG.
*/



/* d�claration des librairies */
libname SOURCE "F:\B�gonia\Mes documents\Refonte PCS, GT Cnis 2017-\Sous-groupe 3\M�nage\Donn�es\lil-1262b.sas7bdat\SAS";
* "libraire de la source utilis�e" ;



/* cr�ation de la table */
data SOURCE.TABLE ; 
set SOURCE.indiv171 SOURCE.indiv172 SOURCE.indiv173 SOURCE.indiv174;
run;



/* D�finition des variables servant � cr�er l'agr�gat � partir des variables d�claratives de l'enqu�te Emploi. Les noms
des variables �quivalentes dans les sources utilis�es pour les tests doivent �videmment remplacer les noms ci-dessous.
A priori, on testerait sur le champ des personnes en emploi. Il s'agit d'un premier mod�le, qui peut �tre adapt� aux 
professions ant�rieures (ch�meurs, inactifs ayant d�j� travaill�), quand les variables d�claratives sont pos�es. Par 
ailleurs, certaines adaptations sont n�cessaires quand on ne dispose pas exactement de */
data TABLE ;
set SOURCE.TABLE;
keep 	RGA /* rang d'interrogation de l'aire : utilis�e ici pour limiter les statistiques aux premi�res interrogations
		(pas de biais d'attrition ou de rotation) ; sp�cifique � l'enqu�te Emploi */ 
		EXTRID /* variable de poids � utiliser avec la restriction � l'aire entrante */

		P CSTOT CSTOTI GSTOT /* variables de PCS de l'enqu�te emploi : CSTOTI en 17 postes sur les actifs occup�s */
		PEUN /* variable d'ISCO */
		ACTEU CHAMP_EMPLOI /* variable d'activit� BIT et de champ r�duit aux personnes en emploi BIT, � utiliser */

		STC /* variable d�clarative de statut salari� - non salari�, avec les salari�s chefs d'entreprise
		compt�s du c�t� des non salari�s ; non redress�e pour �tre coh�rente avec la profession */ 
		CHPUB /* variable d�clarative correspond � la nature publique / priv�e de l'employeur */
		CONTRA /* variable d�clarative de type de contrat pour tous les salari�s (hors fonctionnaires) */ TITC
		NBSALA NBSALB /* variables d�claratives de nombre de salari�s dans l'entreprise (utilis�e pour les ind�pendants) */
		/* variables cr��es � partir des variables d�claratives ci-dessus */
		INDEPENDANT NB10 PRECAIRE PUBLIC POSITION DOMAINE

		/* exemples de variables � analyser en croisement */
		SEXE AGE 

		DDIPL SO;

EXTRID=EXTRID/4; /* poids pour les variables pos�es seulement en vague entrante */

GSTOT = substr(CSTOT,1,1); /* niveau agr�g� des GS */

CHAMP_EMPLOI = (ACTEU = "1") and (GSTOT not in (" ","0")); /* champ d'emploi au sens du BIT et CSTOT connue */

/* champ limit� aux personnes en emploi BIT, donc ; � terme, l'extension aux ch�meurs et inactifs suppose que l'on puisse
avoir la variable pour tout le monde (� partir de l'EEC 2021 ?). Voir pour des extensions avant ? */
if CHAMP_EMPLOI = 1 ;

/* uniquement d�claratif */
INDEPENDANT = (STC in ("1","2","4"," ")); /* statut d�claratif non salari� ou non renseign�, les valeurs manquantes
correspondent � des statuts non d�clar�s, par exemple pour les activit�s informelles, dont on ne pr�suppose pas qu'il
s'agit de contrat salari� (diff�rence avec la r�gle de droit) */

/* uniquement d�claratif, que pour les ind�pendants, en distinguant les travailleurs dans des entreprises mono- et multi-
�tablissements */
NB10 = .;
if INDEPENDANT and NBSALB not in ("13") then do;
	if NBSALB in ("10","11","12") then NB10 = 10; /* 10 salari�s et plus */
	else if NBSALB in ("1","2","3","4","5","6","7","8","9") then NB10 = 1; /* de 1 � 9 salari�s */
	else NB10 = 0; /* 0 salari�s et nombre de salari�s inconnu */
end;
else if INDEPENDANT then do;
	if NBSALA in ("10","11","12") then NB10 = 10; /* 10 salari�s et plus */
	else if NBSALA in ("1","2","3","4","5","6","7","8","9") then NB10 = 1; /* de 1 � 9 salari�s */
	else NB10 = 0; /* 0 salari�s et nombre de salari�s inconnu */
end;

/* uniquement d�claratif : on met tous les types de contrats sauf les CDI, donc les sans contrats, les CDD, l'int�rim,
les contrats saisonniers, l'apprentissage. Sachant que les fonctionnaires titulaires sont du c�t� des valeurs manquantes
sur cette variable. V�rifier que les valeurs manquantes ne sont pas */
PRECAIRE = .;
if not INDEPENDANT then PRECAIRE = (CONTRA in ("0","2","3","4","5"));

/* uniquement d�claratif : on met les 3 FP (E,T,H) mais pas la S�curit� sociale (on n'aura pas cette pr�cision avec 
la variable multi-mode propos�e � terme). */
PUBLIC = .;
if not INDEPENDANT and not PRECAIRE then PUBLIC = (CHPUB in ("3","4","5"));

/* on prend comme indicateur de qualification le groupe socio-professionnel avec les ajustements pr�vus entre A et B, B et C, 
C et D. Il faut la P 2003 (� terme 2020) pour cela. */

/* POSITION, niveau de qualification pour les salari�s, mais qui est quand m�me d�fini pour les P-CS-GS d'ind�pendant
au cas o� il y aurait des incoh�rences de statut. Donc cela doit correspondre exactement � la d�finition A*-B*-C*-D* */ 
POSITION = .;
		if (CSTOT in ("23") or GSTOT in ("1","2") and NB10 in (10)) /* a priori vide sur les salari�s */ 
		or (GSTOT = "3" and P not in ("313a","354b","354c","354d","354g")) /* sont exclus les artistes du spectacle vivant
		et les professeurs (non scolaires) des disciplines artistiques */ 
        or P in ("421a","421b","422a","422b","422c","422d") /* tous les enseignants et les CPE */
        or P in ("431a","431e","434a","435a") /* les sages femmes, cadres du soin infirmier et de travail social (les autres 
		infirmi�res sp�cialis�es, notamment de bloc, ne sont pas int�gr�es car elles sont fusionn�es en P 2020)... Par contre
		les cadres de l'animation socio-culturelle, qui sont fusionn�s en P 2020 avec ceux du travail social, sont int�gr�s. */
        or P in ("451d","452a") /* les officiers de la police nationale et les ing�nieurs du contr�le a�rien (les traducteurs
		et interpr�tes ne sont pas mont�s en A, car ils sont fusionn�s en P 2020 avec des P qui restent en B). */
 		then POSITION = 4; 
		else if P in ("214e") or substr(P,1,3) in ("225","226","227") /* artisans d'art et interm�diaires du commerce,
		des assurances, voyage, immobiliers et prestataires de services. Attention, en P 2003, risque de divergence
		entre le classement des moniteurs d'auto-�cole selon leur statut (en I2 et C). Am�nerait � les laisser en B ? */ 
		or GSTOT in ("3") /* on r�cup�re les professions du groupe 3 exclues ci-dessus */
		or (GSTOT in ("4") and P not in ("422e","423a","433d","435b")) /* sont exclus les surveillants scolaires, 
		les moniteurs d'auto-�cole, les animateurs socio-culturels, les pr�parateurs en pharmacie */
		or P in ("531a","532a","533a","533b") /* policiers nationaux et agents p�nitentiaires �quivalents, gendarmes, 
		sous-officiers subalternes de l'arm�e, pompiers */ 
		or P in ("545a","545b","545c","545d") /* employ�s commerciaux et technique de la banque, des assurances et de la
		s�curit� sociale */ 
		or P in ("546a","546d","546e") /* stewards, hotesses, contr�leurs de train et autres accompagnants des transports,
		le dernier par fusion en P 2020 */
		/* on ne prend pas les employ�s de la bureautique et de l'informatique, car ils sont fusionn�s en P , avec les 
		secr�taires, qui restent en C. */
		or P in ("637b","637c") /* ouvriers d'art et des spectacles, les premiers par fusion en P 2020. */ 
		or P in ("654a","656a") /* les conducteurs de train et matelots, les seconds par fusion en P 2020. */
		/* on n'int�gre pas les dockers, car ils sont fusionn�s en P 2020 avec les conducteurs d'engin, qui sont nombreux
		et moins qualifi�s */ 
        then POSITION = 3;
		else if (GSTOT in ("1","2") and NB10 in (10,1)) /* a priori vide, surtout avec la clause NB10, qui est toujours � vide :
		clause de taille � lever � terme ? Quitte � mettre ces �ventuels salari�s d�claratifs class�s ind�pendants en 
		qualifi�s par d�faut */
		or GSTOT = "4" /* on r�cup�re les professions du groupe 4 exclues ci-dessus */
		or (GSTOT in ("5") and P not in ("525a","525b","525c","525d","533c","534a","534b","541d","542b",
			"551a","552a","553a","554a","554h","554j","555a","561a","561d","561e","561f","563a","563b","563c","564a",
			"564b"))
		/* on garde la d�finition d'Olivier, qui est robuste, en int�grant simplement les contraintes li�es � des fusions
		en P 2020 (534b,). Attention, pour les vendeurs de gros sont exclus en P 2003 et peut-�tre partiellement inclus
		en P 2020, n'�tant plus distingu�s. Une question quand m�me sur la pertinence de mettre en D le 564b, qui appara�t
		assez qualifi�, avec les employ�s de casino, sacristains et agents des pompes fun�bres, etc. */ 
		or (CSTOT in ("62","63","64","65") and P not in ("642a","642b","643a","652a","653a")) 
		/* sont exclus, donc en D, les taxis, VTC, coursiers et livreurs, magasiniers et caristes */
		/* on garde sinon les d�limitations li�es � la CS, y compris en 69, qui est h�t�rog�ne mais y compris au niveau
		des P, qui sont structur�es par m�tiers */ 
		then POSITION= 2;
		else if (GSTOT in ("1","2") and NB10 in (0,.)) /* a priori vide, surtout avec la clause NB10, qui est toujours � 
		vide : clause de taille � lever � terme ? Quitte � mettre ces �ventuels salari�s d�claratifs class�s ind�pendants 
		en qualifi�s par d�faut */
		or GSTOT in ("5","6") 
		then POSITION= 1; 

/* DOMAINE */
DOMAINE = .; /* domaine marginalement affect� pour les PCS d'ind�pendants : les 23 de moyenne ou grande entreprise sont
en administratif, car on suppose qu'ils ou elles font surtout du travail commercial ou gestionnaire ; les professions 
lib�rales techniques sont identifi�es */
if not INDEPENDANT and not PUBLIC and not PRECAIRE then do;
	if P in ("233a","233b","312e","312f","312g") or CSTOT in ("11","12","13","21","38","47","48") or GSTOT = "6" then 
	DOMAINE = 1;
	else if CSTOT in ("22","23","31","33","34","35","37","42","43","44","45","46") or GSTOT = "5" then DOMAINE = 2;
end;

run;



/* Construction des agr�gats dans leurs diff�rentes versions */
data TABLE;
set TABLE;

/* C_SC : sch�ma de classes et sous-classes. */ 
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
 	if PRECAIRE = 1 or substr(P,1,3) in ("563") then C_SC = "D4"; /* on ajoute les professions des services � la personne.
	Il faut avoir conscience que cela introduit un peu de public ici... */
	else if PRECAIRE = 0 and PUBLIC = 1 then C_SC = "D3";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 2 then C_SC = "D2";
    else if PRECAIRE = 0 and PUBLIC = 0 and DOMAINE = 1 then C_SC = "D1";
  end;
end;

/* d�finition des agr�gats au niveau agr�g� : G_ en pr�fixe, pour groupe */
G_C = substr(C_SC,1,1) ;

/* version alternative en reclassant les I. dans A,B,C et D */
G_C_ = G_C;
if C_SC = "I1" then G_C_ = "A";
else if C_SC = "I2" then G_C_ = "B";
else if C_SC = "I3" then G_C_ = "C";
else if C_SC = "I4" then G_C_ = "D";

run;

/* Avec ce programme, on dispose d'une variable de classes et sous-classes, C_SC, avec le niveau agr�g� classique en 5
classes G_C et stratifi� en 4 classes G_C_. */

/* v�rification de la construction : la structure est bien �quilibr�e, 12% chez les ind�pendants et sinon 18%-22%-24%-23%
et en quatre classes : 21%-25%-26%-28% */ 
proc freq data = TABLE ;
tables C_SC G_C G_C_ /missing;
weight EXTRID;
where RGA = "1";
run;
/* Cela fonctionne sur les variables construites en amont, comme attendu ! Cela fonctionne bien pour les pr�caires et
le public (on n'a que les contractuels � dur�e limit�e en pr�caire). Cela fonctionne aussi pour le nombre de salari�s :
seul NBSALB est renseign� pour les ind�pendants ; et les cas non renseign�s en " " et "13" sont en 0. */
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
/* cela a l'air de fonctionner comme attendu, � v�rifier plus pr�cis�ment toutefois ! */
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





/* Exemples de construction d'indicateurs et de red�finition de l'ensemble des agr�gats existants pour les comparaisons */
data TABLE;
set TABLE;

/* exclusion des vagues non entrantes : clause facultative, mais suppose alors de revoir les poids dans l'enqu�te
Emploi */
if RGA = "1";

/* construction d'indicateur � partir d'une variable qualitative */
FEMME = (SEXE = "2");

/* construction d'indicateur � partir d'une variable quantitative */
AGE_30 = (. < AGE < 30);

/* construction d'une variable qualitative � partir d'une variable quantitative */
AGE_D = int(AGE/10);
if AGE_D in (1,2) then AGE_D = 2; /* on tronque � moins de 30 ans */
if AGE_D in (5,6,7,8) then AGE_D = 5; /* on tronque � 50 ans et plus */

/* cr�ation d'une variable suppl�mentaire de HLM */
HLM = (SO in ("3")); 

/* cr�ation de versions alternatives des cat�gories et groupe � comparer */

/* GSTOT_ en 5 postes, avec une agr�gation des agriculteurs et des artisans commer�ants et chefs d'entreprise */
GSTOT_ = GSTOT;
if GSTOT = "1" then GSTOT_ = "2";

/* d�finition d'ISCO 1 et 2 */
ISCO1 = substr(PEUN,1,1);
ISCO2 = substr(PEUN,1,2);

/* impl�mentation d'EseG 1/2 */

/* niveau agr�g� */
ESeG1 = " ";
if ISCO1="1" or (ISCO2="01" and not INDEPENDANT) then ESeG1="1" ;
if ISCO1="2" then ESeG1="2" ;
if (ISCO1="3" and not INDEPENDANT) or (ISCO2="02" and not INDEPENDANT) then ESeG1="3" ;
if ISCO1 in ("3", "4", "5", "6", "7", "8", "9") and INDEPENDANT then ESeG1="4" ;
if (ISCO1="4" or ISCO2 in ("03", "53", "54")) and not INDEPENDANT then ESeG1="5" ;
if ISCO1 in ("7", "8") and not INDEPENDANT  then ESeG1="6" ;
if (ISCO1 in ("6", "9") or ISCO2 in ("51", "52")) and not INDEPENDANT then ESeG1="7" ;

/* niveau d�taill� */
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
/* macro de description d'un indicateur quantitatif pour une grille donn�e : moyenne pour chaque cat�gorie, dans l'ordre 
des cat�gories, puis tri�s par ordre croissant ; construction et impression d'indicateurs de dispersion */
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
CIR = INTERQUARTILE / MOYENNE; /* on privil�gie la moyenne, bien que cela ne soit pas usuel, car elle ne d�pend pas de la 
cat�gorisation, contrairement � la m�diane */
ETR = INTERVALLE / MOYENNE;
run;
data resultat;
set resultat sortie_&V._&W.;
run;
%mend moyenne;



/* Constructions macros de comparaison des prototypes _D (d�finis dans les sources avec la P : "_D" remplacer syst�matiquement
par "_A" quand vous utilisez des sources o� seules les CS existent) avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro qui compare, pour un indicateur, les diff�rentes cat�gorisations agr�g�es V1-2 / A-D et GSTOT, GSTOT_ et ISCO1 
et ESeG1 */
%macro boucle_moyenne_G(V=FEMME);
data resultat ;
set _null_;
run;
%moyenne(V=&V,W=G_C);
%moyenne(V=&V,W=G_C_);
%moyenne(V=&V,W=GSTOT_);
%moyenne(V=&V,W=GSTOT);
%moyenne(V=&V,W=ISCO1); /* cette ligne peut �tre supprim�e en fonction des variables disponibles dans vos sources */
%moyenne(V=&V,W=ESeG1); /* cette ligne peut �tre supprim�e en fonction des variables disponibles dans vos sources */
proc print data = resultat;
var V W MOYENNE ETR CIR GINI;
title "&V G";
run;
%mend boucle_moyenne_G;



/* Constructions macros de comparaison des prototypes _D (d�finis dans les sources avec la P : "_D" remplacer syst�matiquement
par "_A" quand vous utilisez des sources o� seules les CS existent) avec les GS / CS et ISCO 1 / 2 et ESeG1 / 2 */
/* macro qui compare, pour un indicateur, les diff�rentes cat�gorisations d�taill�es V1-2 / A-D et CSTOTI et ISCO2 */
%macro boucle_moyenne_SG(V=FEMME);
data resultat ;
set _null_;
run;
%moyenne(V=&V,W=C_SC);
%moyenne(V=&V,W=CSTOTI);
%moyenne(V=&V,W=EseG2); /* cette ligne peut �tre supprim�e en fonction des variables disponibles dans vos sources */
%moyenne(V=&V,W=ISCO2); /* cette ligne peut �tre supprim�e en fonction des variables disponibles dans vos sources */
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
/* macro de comparaison pour une variable quantitative : par exemple l'�ge (le revenu, apr�s transformation lognormale ; 
etc.) */
/* le calcul du R� ajust� est inclus pour permettre l'ajout de variables de contr�le dans la r�gression, m�me si je ne
pense pas qu'elle soit utile */
%macro GLM(V=AGE,W=G_C);
proc glm data = TABLE ;
class &W ;
model &V = &W ; /* �ventuel ajout de variables de contr�le � droite de &W */
title "&V par &W";
weight EXTRID; /* prise en compte des poids qui peut �tre discut�, donc la clause peut �tre supprim�e */ 
ods output fitstatistics=STATISTIQUE_&V._&W.(keep=dependent rsquare) /*cr�ation de la table STATISTIQUE */
    overallanova=ANOVA_&V._&W.(where=(source='Model')) /* cr�ation de la table ANOVA */
    nobs=NOBS_&V._&W.(keep=nvalue1); /* cr�ation de la table NOBS */
run;
data rsq_&V._&W.;
 merge STATISTIQUE_&V._&W. ANOVA_&V._&W. NOBS_&V._&W.;
 m=df+1;
 adj_rsq=1-(1-rsquare)*((nvalue1-1)/(nvalue1-m)); /* calcul du R2 ajust� */
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



/* Exemples d'utilisation sur les deux exemples de variable de sexe et d'�ge */
/* description des taux de femmes et de moins de 30 ans en comparant les cat�gorisations au niveau agr�g� (G_SJ_V1 et 
G_SJ_V2 (ici d�finis dans une source il y a la P), GS et GS_ (avec 1 et 2 fusionn�s), ISCO1, ESeG1) */
%boucle_moyenne_G(V=FEMME);
%boucle_moyenne_G(V=AGE_30);
/* description des taux de femmes et de moins de 30 ans en comparant les cat�gorisations au niveau d�taill� (SJ_V1 et SJ_V2 
(ici d�finis dans une source il y a la P), CS, ISCO2, ESeG2) */
%boucle_moyenne_SG(V=FEMME);
%boucle_moyenne_SG(V=AGE_30);
/* description de l'association de l'ensemble des cat�gorisations (niveau agr�g� et d�taill�) avec les variables de sexe 
et d'�ge d�cennal tronqu� */
%boucle_croisement(V=SEXE);
%boucle_croisement(V=AGE_D);
/* description de l'association de l'ensemble des cat�gorisations (niveau agr�g� et d�taill�) avec la variable continue
d'�ge */
%boucle_GLM(V=AGE_D);



/* il reste � voir si des statistiques peuvent �tre produites, qui permettent de comparer le degr� d'association ind�pendemment
du nombre de classes, et si cela a un sens... En tous cas, avec les analyses ci-dessus, on a des �l�ments pour se faire 
une premi�re id�e de la distribution des indicateurs sur les diff�rentes cat�gorisations. */  

/* le pouvoir explicatif sur le dipl�me */
%boucle_croisement(V=DDIPL);
/* vivre en HLM */
%boucle_moyenne_G(V=HLM);
%boucle_moyenne_SG(V=HLM);
%boucle_croisement(V=SO);
