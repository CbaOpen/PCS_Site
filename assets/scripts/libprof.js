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
  a.innerHTML = "<option value='...'>...</option>"
  inp.appendChild(a)
  for(var elem in stat){
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='"+stat[elem]+"'>"+elem+"</option>"
  inp.appendChild(a)}
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
	/*var bouton_coder = document.getElementById("bouton_coder")
	bouton_coder.style.display = "none";
	bouton_coder.style.visibility = "hidden";*/
	/* Choix ... */ 
    if(this.value != '...'){
      var statut = this.value
      var code_statut = stat[this.value]
      /* Non rémunéré -> pas d'autres questions */
      if(statut=="non rémunéré, mais travaillez (ou travailliez) avec un membre de votre famille"){
		concat_status(code_statut, "")
		code()
		/*bouton_coder.style.display = "block";
		bouton_coder.style.visibility = "visible";*/
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
        c.innerHTML = "<option value='...'>...</option>"
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
		/*	bouton_coder.style.display = "block";
			bouton_coder.style.visibility = "visible";*/
			code()}
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
