console.log("hola carrito")
$(document).ready(function() {    
    console.log("entre")
    setupStripe();         
     
});

function setupStripe() {
    var stripe_key = $('meta[name="stripe-key"]').attr('content')
    console.log(stripe_key)
    var stripe = Stripe(stripe_key);
    var elements = stripe.elements();
    var card = elements.create('card');
    
    //Add a listener in order to check if theres an error
    card.addEventListener('change', function(event) {
        //the div card-errors contains error details if any
        var displayError = document.getElementById('card-errors');
        document.getElementById('submit-stripe').disabled = false;
        if (event.error) {
        // Display error
        displayError.textContent = event.error.message;
        } else {
        // Clear error
        displayError.textContent = event.error.message;
        }
    });
    //************************************************* */
    card.mount('#card-element');
    var form = document.getElementById('order-details');
    form.addEventListener('submit', function(event) {
        $('#submit-stripe').prop('disabled', true);
        event.preventDefault();
        stripe.createToken(card).then(function(result) {
          if (result.error) {
            // Inform that there was an error.
            var errorElement = document.getElementById('card-errors');
            errorElement.textContent = result.error.message;
          } else {
            // Submits the order
            var $form = $("#order-details");
            // Add a hidden input orders[token]
            $form.append($('<input type="hidden" name="orders[token]"/>').val(result.token.id));
            console.log(result.token.id);
            // Set order type
            //$('#order-type').val('stripe');
            $form.submit();
          }
        });
        return false;
      });    
  




}





/*
$('form').submit(function(event) {
        setupStripe();         
    });
var stripe = Stripe(stripe_key);
    $('form').submit(function(event) {
        //event.preventDefault();
        $.ajax({
            type: "GET",
            url: "cart/purchased",
            dataType: "json",
            success: function(data){
                console.log(data.id) // Will alert Max
            }        
        });
    });
*/