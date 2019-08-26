/* LIBELLES */

/*Tableau contenant toutes les prefessions du bâtiment */
var libprof = [];
/* tableau des mots non signifiants */
var non_signif_words = ["À","AU","D'UN","DANS","DE","DES","DU","EN","ET","LA","LE","OU","SUR","AUX","POUR","AVEC", "CHEZ","D’UNE","D’","L’","PAR",
                      "(",")","/","-"]

/* Récupère le fichier des professions lors du chargement de la page */
$(document).ready(function() {
    $.ajax({
        type: "GET",
        url: "/docs/libprofbtp.csv",
        dataType: "text",
        success: function(data) {processData(data);}
     });    
});

/* Récupère les données du fichier csv contenant les profesions */
function processData(allText) {
   var libproftmp = allText.split(',')
   for(var i=0; i<libproftmp.length; i++)
      libprof.push(libproftmp[i])
}


/* Autocompletion 
	inp : input rentré par l'utilisateur dans la barre de recherche 
	arr : Le tableau dans lequel chercher les mots
	min_letters : nombre minimum de lettre que l'utilisateur doit rentrer avant que l'autocompletion se lance */
function autocomplete(inp, arr, min_letters) {
  var currentFocus;
  var statut = document.getElementById('statut')
  var position = document.getElementById('position')
  var code = document.getElementById('code')
  var res_statut = document.getElementById('res_statut')
  	statut.style.display = "none";
	statut.style.visibility = "hidden";
	position.style.display = "none";
	position.style.visibility = "hidden";
	res_statut.innerHTML=""
	code.innerHTML = ""
  inp.addEventListener("input", function(e) {
      var a, b, i, val = this.value;
      rep=document.getElementById('rep_autocompletion');
      /* Ferme toutes les listes ouvertes de valeurs autocomplétées */
      closeAllLists();
      /* rien écrit */
      if (!val) { 
		rep.innerHTML = "";
$('#statut option').prop('selected', function() {return this.defaultSelected;});
	statut.style.display = "none";
	statut.style.visibility = "hidden";
$('#position option').prop('selected', function() {return this.defaultSelected;});
	position.style.display = "none";
	position.style.visibility = "hidden";
	res_statut.innerHTML=""
	code.innerHTML = ""
		return false;}
		/* moins de  lettres */
      if(val.length < min_letters){  
		rep.innerHTML = "Vous devez rentrer au moins 3 lettres pour avoir des proposition de profession";
$('#statut option').prop('selected', function() {return this.defaultSelected;});
	statut.style.display = "none";
	statut.style.visibility = "hidden";
	$('#position option').prop('selected', function() {return this.defaultSelected;});
	position.style.display = "none";
	position.style.visibility = "hidden";
	res_statut.innerHTML=""
	code.innerHTML = ""
		  }
        if(val.length >= min_letters){
		rep.innerHTML = ""	
        currentFocus = -1;
        /* Crée une balise div qui contiendra toutes les valeurs autocomplétées */
        a = document.createElement("DIV");
        a.setAttribute("id", this.id + "autocomplete-list");
        a.setAttribute("class", "autocomplete-items");
        this.parentNode.appendChild(a);

        for (var elem in arr){
          var valSplit = arr[elem].split(' ')
          /* Teste pour le début des mots uniquement */
          if (is_significant(val, non_signif_words) && arr[elem].substr(0, val.length).toUpperCase() == val.toUpperCase()) {
            b = document.createElement("DIV");
            b.innerHTML = "<strong>" + arr[elem].substr(0, val.length) + "</strong>";
            b.innerHTML += arr[elem].substr(val.length);
            b.innerHTML += "<input type='hidden' value='" + arr[elem] + "'>";
            b.addEventListener("click", function(e) {
                inp.value = this.getElementsByTagName("input")[0].value;
                closeAllLists();
            });
            a.appendChild(b);
            /* un mot a été trouvé, donc le metier peut exister */
            var metier_trouve = true;
          }
          /* Teste pour tous les autres mots du tableau si l'input matche */
          else if(valSplit.length > 1){
            for(j=1; j<valSplit.length; j++){
              if(is_significant(valSplit[j], non_signif_words) && valSplit[j].substr(0, val.length).toUpperCase() == val.toUpperCase()){
                b = document.createElement("DIV");
                b.innerHTML = ""
                for(k=0; k<j; k++)
                  b.innerHTML += valSplit[k] + " ";
                b.innerHTML += "<strong>" + valSplit[j].substr(0, val.length) + "</strong>";
                b.innerHTML += valSplit[j].substr(val.length) + " ";
                for(k=j+1; k<valSplit.length; k++)
                  b.innerHTML += valSplit[k] + " ";
                b.innerHTML += "<input type='hidden' value='" + arr[elem] + "'>";
                b.addEventListener("click", function(e) {
                    inp.value = this.getElementsByTagName("input")[0].value;
                    closeAllLists();
                });
                a.appendChild(b);
                break;
              }
            }
          } 
          
        }
        /* aucun métier trouvé dans la liste */
		if(!metier_trouve){
			rep.innerHTML = "Votre libellé n’est pas dans la liste, merci de le vérifier. Si vous confirmez votre déclaration nous nous excusons pour cet oubli.";
$('#statut option').prop('selected', function() {return this.defaultSelected;});
	statut.style.display = "none";
	statut.style.visibility = "hidden";
	$('#position option').prop('selected', function() {return this.defaultSelected;});
	position.style.display = "none";
	position.style.visibility = "hidden";
	res_statut.innerHTML=""
	code.innerHTML = ""
		}
		/* métier trouvé, on peut passer à la question suivante */
		else if(metier_trouve){
			document.getElementById('statut').style.display = "block";
			document.getElementById('statut').style.visibility = "visible";
		}
	}
      
  });
  /*execute a function presses a key on the keyboard:*/
  inp.addEventListener("keydown", function(e) {
      var x = document.getElementById(this.id + "autocomplete-list");
      if (x) x = x.getElementsByTagName("div");
      if (e.keyCode == 40) {
        /*If the arrow DOWN key is pressed,
        increase the currentFocus variable:*/
        currentFocus++;
        /*and and make the current item more visible:*/
        addActive(x);
      } else if (e.keyCode == 38) { //up
        /*If the arrow UP key is pressed,
        decrease the currentFocus variable:*/
        currentFocus--;
        /*and and make the current item more visible:*/
        addActive(x);
      } else if (e.keyCode == 13) {
        /*If the ENTER key is pressed, prevent the form from being submitted,*/
        e.preventDefault();
        if (currentFocus > -1) {
          /*and simulate a click on the "active" item:*/
          if (x) x[currentFocus].click();
        }
      }
  });
  function addActive(x) {
    /*a function to classify an item as "active":*/
    if (!x) return false;
    /*start by removing the "active" class on all items:*/
    removeActive(x);
    if (currentFocus >= x.length) currentFocus = 0;
    if (currentFocus < 0) currentFocus = (x.length - 1);
    /*add class "autocomplete-active":*/
    x[currentFocus].classList.add("autocomplete-active");
  }
  function removeActive(x) {
    /*a function to remove the "active" class from all autocomplete items:*/
    for (var i = 0; i < x.length; i++) {
      x[i].classList.remove("autocomplete-active");
    }
  }
  function closeAllLists(elmnt) {
    /*close all autocomplete lists in the document,
    except the one passed as an argument:*/
    var x = document.getElementsByClassName("autocomplete-items");
    for (var i = 0; i < x.length; i++) {
      if (elmnt != x[i] && elmnt != inp) {
        x[i].parentNode.removeChild(x[i]);
      }
    }
  }
  /*execute a function when someone clicks in the document:*/
  document.addEventListener("click", function (e) {
      closeAllLists(e.target);
  });
}
/* fin fonction autocompletion*/


/* Test si un mot est signifiant ou non */
function is_significant(word, tab_non_signif){
  for(var i=0; i<tab_non_signif.length; i++){
    if(tab_non_signif[i] == word.toUpperCase())
      return false;
  }
  return true;
}






/*initiate the autocomplete function on the "prof" element, and pass along the libprof array as possible autocomplete values:*/
autocomplete(document.getElementById("prof"), libprof, 3);



/* QUESTIONS */ 

/*statut */
var stat = {
	"à votre compte (y compris gérant de société ou chef d’entreprise salarié)" : 'inde',
	"salarié de la fonction publique" : 'pub',
	"salarié d’un autre employeur (entreprise, association, de particulier, etc.)" : 'priv',
	"non rémunéré, mais travaillez (ou travailliez) avec un membre de votre famille" : 'aid_fam'}

        
/* position */        
var pos_priv = {"manœuvre, ouvrier spécialisé": '_onq', 
				"ouvrier qualifié, technicien d’atelier": '_oq', 
				"employé de bureau, de commerce, de services" : '_emp',
				"agent de maîtrise (y. c. administrative ou commerciale)" :'_am',
				"technicien" : '_tec',
				"ingénieur, cadre d’entreprise" : '_cad',
				"dans une autre situation" : '_nr'}
                          
var pos_pub = {"manœuvre, ouvrier spécialisé" : '_nr',
				"ouvrier qualifié, technicien d’atelier" : '_nr',
				"technicien" :'_nr',
				"agent de catégorie C de la fonction publique" : '_catC',
				"agent de catégorie B de la fonction publique" : '_catB',
				"agent de catégorie A de la fonction publique" : '_catA',
				"dans une autre situation" :'_nr'}

var inde = {"une seule personne : vous travaillez seul": '_0_9', 
			"entre 2 et 10 personnes": '_0_9', 
			"entre 11 et 49 personnes" : '_10_49', 
			"50 personnes ou plus": '_50_499'}
			
/* résultat statut + position */
var cadre_prof = {'priv_cad': "Salarié du privé cadre", 'priv_tec' : "Salarié du privé technicien", 'priv_am' : "Salarié du privé agent de maintenance", 'priv_emp' : "Salarié du privé, employé",
        'priv_oq' : "Salarié du privé, ouvrier qualifié", 'priv_onq' : "Salarié du privé, ouvrier non qualifié", 'priv_nr' : "Salarié du privé, valeur par défaut",
        'pub_catA' : "Salarié du public de catégorie A", 'pub_catB' : "Salarié du public de catégorie B", 'pub_catC' : "Salarié du public de catégorie C",
        'pub_nr' : "Salarié du public, valeur par défaut", 'sal_par' : "Salarié particulier", 'inde_0_9' : "Non salarié, entreprise de moins de 10 employés",
        'inde_10_49' : "Non salarié, entreprise d’entre 10 et 49 employés", 'inde_50_499' : "Non salarié, entreprise d’entre 50 et 499 employés",'inde>500' : "Non salarié, entreprise de plus de 500 employés",
        'inde_nr' : "Non salarié, valeur par défaut",'aid_fam' : "Aide familial",'ssvaran' : "Autre"}

/* Pose les questions pour avoir le statut de la profession */
function get_status(inp){
  /* Question 2 */

  var a = document.createElement("OPTION")
  a.innerHTML = "<option selected value='...'>...</option>"
  inp.appendChild(a)
  for(var elem in stat){
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='"+stat[elem]+"'>"+elem+"</option>"
  inp.appendChild(a)}
	inp.options[inp.options.selectedIndex].selected = true;
  inp.addEventListener("input", function(e){
    /* Choix question 2*/
    /* Initialisation variables */
	var position = document.getElementById("position")
	position.style.display = "none";
	position.style.visibility = "hidden";
	var res_statut = document.getElementById("res_statut")
	res_statut.innerHTML=""
	var res_code = document.getElementById("code")
	res_code.innerHTML = ""

	/* Choix ... */ 
    if(this.value != '...'){
      var statut = this.value
      var code_statut = stat[this.value]
      /* Non rémunéré -> pas d'autres questions */
      if(statut=="non rémunéré, mais travaillez (ou travailliez) avec un membre de votre famille"){
		concat_status(code_statut, "")
		code()
      }
      /* Question 3*/
      else{
	position.style.display = "block";
	position.style.visibility = "visible";
      /* Intitulé question 3c */
      if(statut == "à votre compte (y compris gérant de société ou chef d’entreprise salarié)"){
		  position.innerHTML = "En vous comptant, combien de personnes travaillent dans votre entreprise ?"}
	/* Intitulé question 3a et b */
	  else{
		  position.innerHTML = "Dans cet emploi êtes-vous ? "
	  }
		var b = document.createElement("SELECT")
        b.innerHTML = "<select id='position_prof' name='positionprof'></select>"
        position.appendChild(b)
        var c = document.createElement("OPTION")
        c.innerHTML = "<option selected value='...'>...</option>"
        b.appendChild(c)
        /* Réponse question 3a */
        if(statut == "salarié d’un autre employeur (entreprise, association, de particulier, etc.)"){
			var arr = pos_priv}
		/* Réponse question 3b*/
        else if(statut == "salarié de la fonction publique"){
			var arr = pos_pub}
		       /* Réponse question 3c */
        else if(statut == "à votre compte (y compris gérant de société ou chef d’entreprise salarié)"){
			var arr = inde}
		for(var elem in arr){
        c = document.createElement("OPTION")
        c.innerHTML = "<option value='"+arr[elem]+"'>"+elem+"</option>"
        b.appendChild(c)
        }
        b.addEventListener("input", function(e){
			if(this.value != '...'){
			var position_prof = this.value
			var code_position = arr[this.value]
			concat_status(code_statut, code_position)
			code()
			}
  })
}}
  })
}

var code_qt = "..."

/* Concatène le résultat des 3 questions */
function concat_status(code_statut, code_position){
  code_qt = code_statut + code_position

  var rep = document.getElementById("res_statut")
    rep.innerHTML = "<br>Votre statut est : <strong>" + cadre_prof[code_qt] + "</strong>"
}

/* Fonction executé pour obtenir le code de sa profession */
function code(){
	$.ajax({
	    type: "GET",
	    url: "/docs/index_alphabetique_numerique_compact.csv",
	    dataType: "text",
	    success: function(data) {findCode(data, document.getElementById("prof").value, code_qt);}
	 }); 
}


function findCode(allText, valProf, code_qt){
	var b = document.getElementById("code")
	if(valProf.length > 4 && code_qt.length > 4){
	   var lines = allText.split(/\r\n|\n/)
	   var headertmp = lines[0].split(',')
	   var header = {};
	   for(var i =0; i<headertmp.length; i++)
	   		header[headertmp[i]] = i
	    for(var i=1; i<lines.length; i++){
	    	var l = lines[i].split(',')
	    	if(l[header['libm']] == valProf || l[header['libf']] == valProf){
	    		b.innerHTML = "Le code de votre profession est : <strong>"+l[header[code_qt]]+"</strong>.";
	    	}
	    }
	}

}

get_status(document.getElementById("statut_prof"))

