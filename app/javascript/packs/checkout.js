$(document).ready(function() {    
    get_secret().then(response => {
                    console.log(response.client_secret)
                    secret = response.client_secret
                    var stripe_key = $('meta[name="stripe-key"]').attr('content')
                    console.log(stripe_key)
                    const Client_appearance = {
                      theme: 'night'
                    };
                    const options = {
                      clientSecret: secret,
                      // Fully customizable with appearance API.
                      appearance: Client_appearance,
                    };
                    const stripe = Stripe(stripe_key);
                    // Set up Stripe.js and Elements to use in checkout form, passing the client secret obtained in step 2
                    const elements = stripe.elements(options);
                    // Create and mount the Payment Element
                    const paymentElement = elements.create('payment');
                    paymentElement.mount('#payment-element');
                    send_payment(stripe,elements);
    })
});

function get_secret() {
  return fetch('/checkout/secret')
    .then((response) => response.json())
    .then((data) =>{
                    //console.log(data);
                    //console.log(data.client_secret);
                    var $form = $("#order-details");
                    $form.append($('<input type="hidden" name="orders[token]"/>').val(data.client_secret));
                    return data  
    });
};

function send_payment(stripe,elements){
  const form = document.getElementById('payment-form');

  form.addEventListener('submit', async (event) => {
    event.preventDefault();
    const {error} = await stripe.confirmPayment({
      //`Elements` instance that was used to create the Payment Element
      elements,
      confirmParams: {
        return_url: 'http://localhost:3000/checkout/confirm',
      },
    });

  if (error) {
    // This point will only be reached if there is an immediate error when
    // confirming the payment. Show error to your customer (for example, payment
    // details incomplete)
    const messageContainer = document.querySelector('#error-message');
    messageContainer.textContent = error.message;
  } else {
    // Your customer will be redirected to your `return_url`. For some payment
    // methods like iDEAL, your customer will be redirected to an intermediate
    // site first to authorize the payment, then redirected to the `return_url`.
  }
});
}

