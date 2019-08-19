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


/* Test si un mot est signifiant ou non */
function is_significant(word, tab_non_signif){
  for(var i=0; i<tab_non_signif.length; i++){
    if(tab_non_signif[i] == word.toUpperCase())
      return false;
  }
  return true;
}

/* Fonction executé lorsque l'utilisateur appuis sur le bouton "coder" */
function code(){
	$.ajax({
	    type: "GET",
	    url: "/docs/index_alphabetique_numerique_compact.csv",
	    dataType: "text",
	    success: function(data) {findCode(data, document.getElementById("prof").value, statut);}
	 }); 
}

/* recherche le code du libellé avec les données données par l'utilisateur */
function findCode(allText, valProf, statut){
	var b = document.getElementById("code")
	b.innerHTML = ""
	if(statut == "..."){
	   	b.innerHTML = "Veuillez donner le statut de votre profession";
	}
	if(valProf.length > 4 && statut.length > 4){
	   var lines = allText.split(/\r\n|\n/)
	   var headertmp = lines[0].split(',')
	   var header = {};
	   for(var i =0; i<headertmp.length; i++)
	   		header[headertmp[i]] = i
	    for(var i=1; i<lines.length; i++){
	    	var l = lines[i].split(',')
	    	if(l[header['libm']] == valProf || l[header['libf']] == valProf){
	    		b.innerHTML = "Le code de votre profession est : <strong>"+l[header[statut]]+"</strong>.";
	    	}
	    }
	}

}


/*initiate the autocomplete function on the "prof" element, and pass along the libprof array as possible autocomplete values:*/
autocomplete(document.getElementById("prof"), libprof, 3);
