/*Tableau contenant toutes les prefessions du bâtiment */
var libprof = [];
/* */
$(document).ready(function() {
    $.ajax({
        type: "GET",
        url: "/docs/btpear2017_codifie_R.csv",
        dataType: "text",
        success: function(data) {processData(data);}
     });    
});

/* Récupère les données du fichier csv contenant les profesions */
function processData(allText) {
    var allTextLines = allText.split(/\r\n|\n/);
   var headers = allTextLines[0].split(',');
    var jobs = [];
   var profcount = []

    for (var i=1; i<allTextLines.length; i++) {
        var data = allTextLines[i].split(',');
        if (data.length == headers.length) {
            var tarr = {};
            for (var j=0; j<headers.length; j++) {
                tarr[headers[j].substring(1, headers[j].length-1)] = data[j].substring(1, data[j].length-1)
            }
            jobs.push(tarr);
            libprof.push(jobs[jobs.length-1][headers[3].substring(1, headers[3].length-1)])
            profcount[libprof[libprof.length-1]] = 0;
        }
    }
    
    for(var i=0; i<jobs.length; i++){
      libprof.push(jobs[i][headers[3].substring(1, headers[3].length-1)])
      profcount[libprof[i]] = 0;
    }
    for(var i=0; i<libprof.length; i++){
      profcount[libprof[i]] += 1;
      if(profcount[libprof[i]] > 1){
        libprof.splice(i,1)
        i--;
      }
    }

  let datafile = ""
  for(var i=0; i<libprof.length; i++)
    datafile += libprof[i] + ","
  datafile = datafile.substring(0, datafile.length-1)
  console.log(datafile)
}
