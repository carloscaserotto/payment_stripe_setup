console.log("hello")
$(document).ready(function() {    
    $('input[type="radio"][data-behavior="clickable"]').click(function(evt) {
      //console.log("chose: " + $(this).val());
      var newActiveTabID = $(this).val();
      console.log(newActiveTabID);
      $('.paymentSelectionTab').removeClass('active');
      $('#tab-' + newActiveTabID).addClass('active');
    });
    
    setupStripe();    
        
});

//setupStripe***************************************************************
function setupStripe() {
    //console.log("Stripe")
    //Initialize stripe with publishable key
    var stripe_key = $('meta[name="stripe-key"]').attr('content')
    //console.log(stripe_key)
    var stripe = Stripe(stripe_key);
    //console.log(stripe)
    //Stripe.setPublishableKey($('meta[name="stripe-key"]').attr('content'))
    //Create Stripe credit card elements.
    var elements = stripe.elements();
    //console.log(elements)
    var card = elements.create('card');
    //console.log(card)
    
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
          displayError.textContent = 'si no hay errores';
        }
      });
    
    // Mount Stripe card element in the #card-element div.
    card.mount('#card-element');
    //console.log(card.mount)
    var form = document.getElementById('order-details');
    //console.log(form)
    // This will be called when the #submit-stripe button is clicked by the user.
    form.addEventListener('submit', function(event) {
      //console.log(event)
      $('#submit-stripe').prop('disabled', true);
      event.preventDefault();
      stripe.createToken(card).then(function(result) {
        //console.log(result)
        alert(result.token.id)
        if (result.error) {
          // Inform that there was an error.
          var errorElement = document.getElementById('card-errors');
          errorElement.textContent = result.error.message;
        } else {
           //alert(result.token.id)
          // Submits the order
          var $form = $("#order-details");
          // Add a hidden input orders[token]
          $form.append($('<input type="hidden" name="orders[token]"/>').val(result.token.id));
          // Set order type
          $('#order-type').val('stripe');
          $form.submit();
        }
      });
      return false;
    });    
}


