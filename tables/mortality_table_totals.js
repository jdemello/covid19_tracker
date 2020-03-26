function(row, data, start, end, display) {
  
  var api = this.api(), data;
  
  var ind = [2,3,4];
  
  for(i = 0; i < ind.length; i++){
    
    total = api.column(ind[i]).data().reduce((a, b) => {return a + b}, 0);
    
    $(api.column(ind[i]).footer() ).html('Column total: ' + total);
  }
}