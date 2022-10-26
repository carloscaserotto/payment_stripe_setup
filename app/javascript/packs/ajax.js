$(document).ready(function() {    
    $.ajax({
      type: "GET",
      url: "cart/purchased",
      dataType: "json",
      success: function(data){
          console.log(data.id) // Will alert Max
      }        
  });
});