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
