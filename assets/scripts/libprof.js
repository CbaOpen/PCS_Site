/*Tableau contenant toutes les prefessions du bâtiment */
var libprof = [];
/* tableau des mots non signifiants */
var non_signif_words = ["À","AU","D'UN","DANS","DE","DES","DU","EN","ET","LA","LE","OU","SUR","AUX","POUR","AVEC", "CHEZ","D’UNE","D’","L’","PAR",
                      "(",")","/","-"]
var cadre_prof_inv = {"Salarié du privé cadre":'priv_cad', "Salarié du privé technicien":'priv_tec', "Salarié du privé agent de maintenance":'priv_am', "Salarié du privé, employé":'priv_emp',
				"Salarié du privé, ouvrier qualifié":'priv_oq', "Salarié du privé, ouvrier non qualifié":'priv_onq', "Salarié du privé, valeur par défaut":'priv_nr',
				"Salarié du public de catégorie A":'pub_catA', "Salarié du public de catégorie B":'pub_catB', "Salarié du public de catégorie C":'pub_catC',
				"Salarié du public, valeur par défaut":'pub_nr', "Salarié particulier":'sal_par', "Non salarié, entreprise de moins de 10 employés":'inde_0_9',
				"Non salarié, entreprise d’entre 10 et 49 employés":'inde_10_49', "Non salarié, entreprise d’entre 50 et 499 employés":'inde_50_499',"Non salarié, entreprise de plus de 500 employés":'inde>500',
				"Non salarié, valeur par défaut":'inde_nr',"Aide familial":'aid_fam',"Autre":'ssvaran'}

var statut_priv = {"Cadre": 'cad', "Technicien": 'tec', "Agent de maintenance": 'am', "Employé": 'emp', "Ouvrier qualifier": 'oq', "Ouvrier non qualifier": 'onq', "Autre": 'nr',
                  "Particulier": 'sal_par', "Non Salarié": 'inde', "Aide familial": 'aide_fam', "Autre": 'ssvaran'}
var statut_pub = {"Catégorie A": 'catA', "Catégorie B": 'catB', "Catégorie C": 'catC', "Autre": 'nr'}

var inde = {"Entreprise moins de 10 employés": '_0_9', "Entreprise entre 10 et 49 employés": '_10_49', "Entreprise entre 50 et 499": '_50_499', "Entreprise de plus de 500 employés": '>500', "Autre": 'nr'}

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

function get_status(inp){
  var a = document.createElement("OPTION")
  a.innerHTML = "<option value='...'>...</option>"
  inp.appendChild(a)
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='priv'>Privé</option>"
  inp.appendChild(a)
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='pub'>Public</option>"
  inp.appendChild(a)
  inp.addEventListener("input", function(e){
    if(this.value != '...'){
      a = document.getElementById("statut")
      a.innerHTML = "Quel est votre statut ? "
      var b = document.createElement("SELECT")
      b.innerHTML = "<select id='statut_prof' name='statutprof'></select>"
      a.appendChild(b)
      var c = document.createElement("OPTION")
      c.innerHTML = "<option value='...'>...</option>"
      b.appendChild(c)
      var arr;
      if(this.value == 'Privé')
        arr = statut_priv
      else
        arr = statut_pub
      for(var elem in arr){
        c = document.createElement("OPTION")
        c.innerHTML = "<option value='"+ statut_priv[elem] +"'>"+elem+"</option>"
        b.appendChild(c)
      }
      if(this.value == "Privé"){
        b.addEventListener("input", function(e){
          if(statut_priv[this.value] == "inde"){
            a = document.getElementById("inde")
            a.innerHTML = "Combien de salarié avez-vous dans votre entreprise ? "
            c = document.createElement("SELECT")
            c.innerHTML = "<select id='inde_prof' name='indeprof'></select>"
            a.appendChild(c)
            var d =document.createElement("OPTION")
            d.innerHTML = "<option value='...'>...</option>"
            c.appendChild(d)
            for(var elem in inde){
                d = document.createElement("OPTION")
                d.innerHTML = "<option value='"+ inde[elem] +"'>"+elem+"</option>"
                c.appendChild(d)       
            }
          }
          else {
            a = document.getElementById("inde")
            a.innerHTML = ""
          }

        })
      }
    }
    else {
      a = document.getElementById("statut")
      a.innerHTML = ''
    }

  })
}


/* Autocompletion 
	inp : input rentré par l'utilisateur dans la barre de recherche 
	arr : Le tableau dans lequel chercher les mots
	min_letters : nombre minimum de lettre que l'utilisateur doit rentrer avant que l'autocomletion se lance */
function autocomplete(inp, arr, min_letters) {
  var currentFocus;
  inp.addEventListener("input", function(e) {
      var a, b, i, val = this.value;
      
      /* Ferme toutes les listes ouvertes de valeurs autocomplétées */
      closeAllLists();
      if (!val) { return false;}
        if(val.length >= min_letters){
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



function is_significant(word, tab_non_signif){
  for(var i=0; i<tab_non_signif.length; i++){
    if(tab_non_signif[i] == word.toUpperCase())
      return false;
  }
  return true;
}
var testArr = ["est aux miel", "test"]
/*initiate the autocomplete function on the "prof" element, and pass along the libprof array as possible autocomplete values:*/
get_status(document.getElementById("pos_prof"))
// autocomplete(document.getElementById("prof"), libprof, 3);
// autocomplete(document.getElementById("cadreprof"), cadre_prof, 0);

/* Fonction executé lorsque l'utilisateur appuis sur le bouton "coder" */
function code(){
	$.ajax({
	    type: "GET",
	    url: "/docs/btpear2017.csv",
	    dataType: "text",
	    success: function(data) {findCode(data, document.getElementById("prof").value, document.getElementById("cadreprof").value);}
	 }); 
}

/* recherche le code du libellé avec les données données par l'utilisateur */
function findCode(allText, valProf, valCadreProf){
	if(valProf.length > 4 && valCadreProf.length > 4){
	   var lines = allText.split(/\r\n|\n/)
	   var linesctn = 0;
	   for(var i=0; i<lines.length; i++){
	   		if(lines[i].search(new RegExp(","+valProf+","+cadre_prof_inv[valCadreProf])) >= 0){
	   			console.log(lines[i]);
	   			linesctn++;
	   			var line = lines[i].split(',');
	 			var b = document.getElementById("code")
	 			b.innerHTML = "Le code de votre profession est : <strong>"+line[1]+"</strong>.";
	   		}
	   }
	   if(linesctn == 0){
	   	var b = document.getElementById("code")
	   	b.innerHTML = "Le code de votre profession n'a pas été trouvé."
	   }
	}

}
