
var statut = "...";
/* statut de la profession */
var cadre_prof = {'priv_cad': "Salarié du privé cadre", 'priv_tec' : "Salarié du privé technicien", 'priv_am' : "Salarié du privé agent de maintenance", 'priv_emp' : "Salarié du privé, employé",
        'priv_oq' : "Salarié du privé, ouvrier qualifié", 'priv_onq' : "Salarié du privé, ouvrier non qualifié", 'priv_nr' : "Salarié du privé, valeur par défaut",
        'pub_catA' : "Salarié du public de catégorie A", 'pub_catB' : "Salarié du public de catégorie B", 'pub_catC' : "Salarié du public de catégorie C",
        'pub_nr' : "Salarié du public, valeur par défaut", 'sal_par' : "Salarié particulier", 'inde_0_9' : "Non salarié, entreprise de moins de 10 employés",
        'inde_10_49' : "Non salarié, entreprise d’entre 10 et 49 employés", 'inde_50_499' : "Non salarié, entreprise d’entre 50 et 499 employés",'inde>500' : "Non salarié, entreprise de plus de 500 employés",
        'inde_nr' : "Non salarié, valeur par défaut",'aid_fam' : "Aide familial",'ssvaran' : "Autre"}

var statut_priv = {"Cadre": 'cad', "Technicien": 'tec', "Agent de maintenance": 'am', "Employé": 'emp', "Ouvrier qualifier": 'oq', "Ouvrier non qualifier": 'onq', "Autre": 'nr',
                  "Particulier": 'sal_par', "Non Salarié": 'inde', "Aide familial": 'aid_fam', "Autre": 'nr'}
var statut_pub = {"Catégorie A": 'catA', "Catégorie B": 'catB', "Catégorie C": 'catC', "Autre": 'nr'}

var inde = {"Entreprise moins de 10 employés": '_0_9', "Entreprise entre 10 et 49 employés": '_10_49', "Entreprise entre 50 et 499": '_50_499', "Entreprise de plus de 500 employés": '>500', "Autre": '_nr'}

/* Pose les questions pour avoir le statut de la profession */
function get_status(inp){
  var pos_prof, st_prof="", st_inde = "";
  /* Question 1 */
  var a = document.createElement("OPTION")
  a.innerHTML = "<option value='...'>...</option>"
  inp.appendChild(a)
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='priv'>Privé</option>"
  inp.appendChild(a)
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='pub'>Public</option>"
  inp.appendChild(a)
  a = document.createElement("OPTION")
  a.innerHTML = "<option value='ssvaran'>Autre</option>"
  inp.appendChild(a)
  inp.addEventListener("input", function(e){
    /* Question 2 */
    var rep = document.getElementById("statut_prof")
    rep.innerHTML = ""
    if(this.value != '...'){
      pos_prof = this.value
      if(pos_prof=="Autre"){
        concat_status("ssvaran", st_prof, st_inde)
        a = document.getElementById("statut")
        a.innerHTML = ''
        a = document.getElementById("inde")
        a.innerHTML = ""
      }
      else{
        a = document.getElementById("statut")
        a.innerHTML = "Quel est votre statut ? "
        var b = document.createElement("SELECT")
        b.innerHTML = "<select id='statut_prof' name='statutprof'></select>"
        a.appendChild(b)
        var c = document.createElement("OPTION")
        c.innerHTML = "<option value='...'>...</option>"
        b.appendChild(c)
        var arr;
        if(pos_prof == 'Privé')
          arr = statut_priv
        else
          arr = statut_pub
        for(var elem in arr){
          c = document.createElement("OPTION")
          c.innerHTML = "<option value='"+ statut_priv[elem] +"'>"+elem+"</option>"
          b.appendChild(c)
        }
        b.addEventListener("input", function(e){
          /* Question 3 */
          var rep = document.getElementById("statut_prof")
          rep.innerHTML = ""
          if(this.value != '...'){
            st_prof = arr[this.value]
            if(pos_prof == "Privé"){
              if(st_prof == "inde"){
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
                c.addEventListener("input", function(e){
                  var rep = document.getElementById("statut_prof")
                  rep.innerHTML = ""
                  if(this.value != '...'){
                    st_inde = inde[this.value]
                    concat_status(pos_prof, st_prof, st_inde)
                  }
                })
              }
              else {
                a = document.getElementById("inde")
                a.innerHTML = ""
                concat_status(pos_prof, st_prof, st_inde)
              }
            }
            else
              concat_status(pos_prof, st_prof, st_inde)
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

/* Concatène le résultat des 3 questions */
function concat_status(pos_prof, st_prof, st_inde){
  if(st_prof == "inde")
    statut = st_prof+st_inde
  else if (pos_prof == "ssvaran")
    statut = pos_prof
  else if (st_prof == "sal_par" || st_prof == "aid_fam")
    statut = st_prof
  else{
    if(pos_prof == "Privé")
      statut = "priv_"+st_prof
    else
      statut = "pub_"+st_prof
  }
  var rep = document.getElementById("statut_prof")
    rep.innerHTML = "<br>Votre statut est : <strong>" + cadre_prof[statut] + "</strong>"

}

get_status(document.getElementById("pos_prof"))
