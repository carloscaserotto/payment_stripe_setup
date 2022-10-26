Rails.application.routes.draw do
  
  get '/articles', to: 'articles#index'
  get '/articles/new', to: 'articles#new'
  post '/articles', to: 'articles#create'
  devise_for :users
  #resources :users
  root to: "home#welcome"
  get '/orders', to: 'orders#index'
  post '/orders/submit', to: 'orders#submit'

  get '/cart', to: 'cart#index'
  post '/cart/purchased', to: 'cart#purchased' 

  get '/checkout', to: 'checkout#order' 
  get '/checkout/secret', to: 'checkout#secret' 
  get '/checkout/confirm', to: 'checkout#confirm' 
  
  
  post '/create-payment-intent', to: 'checkout#secret'
  get '/confirm-payment-intent', to: 'checkout#confirm'  
  post '/confirm-payment-intent', to: 'checkout#confirm' 
  
  
end
