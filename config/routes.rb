require "api_constraints"
Rails.application.routes.draw do

  devise_for :users

  resources :home

  resources :lessons do
    member do
      patch :accept
      patch :refuse
    end
  end
 
  resources :implementer_requests do
    member do
      patch :accept
      patch :refuse
    end
  end

  resources :employees do
    collection do
      post :getCompanyUsers
      post :notifyUser
    end
  end

  resources :employees
  resources :companies
  resources :programs
  resources :schools

  root 'employees#show'

  # API Routes
  namespace :api, defaults: {format: 'json'} do
    match "base" => "base#index", :via => :post
    scope module: :v1, constraints: ApiConstraints.new(version: 1) do
      match '/ios/login' => 'ios#login', :via => :post
      match '/ios/create_device' => 'ios#create_device', :via => :post
      match '/ios/android_update' => 'ios#android_update', :via => :post
      match '/ios/age_groups' => 'ios#age_groups', :via => :post
      match '/ios/sign_up' => 'ios#sign_up', :via => :post
      match '/ios/get_past_events' => 'ios#get_past_events', :via => :post
      match '/ios/get_more_past_events' => 'ios#get_more_past_events', :via => :post
      match '/ios/get_upcoming_events' => 'ios#get_upcoming_events', :via => :post
      match '/ios/get_more_upcoming_events' => 'ios#get_more_upcoming_events', :via => :post
      match '/ios/rsvp' => 'ios#rsvp', :via => :post
      match '/ios/get_feedbacks' => 'ios#get_feedbacks', :via => :post
      match '/ios/add_feedback' => 'ios#add_feedback', :via => :post
      match '/ios/get_event_pictures' => 'ios#get_event_pictures', :via => :post
      match '/ios/add_event_picture' => 'ios#add_event_picture', :via => :post
      match '/ios/update_profile' => 'ios#update_profile', :via => :post
      match '/ios/update_profile_picture' => 'ios#update_profile_picture', :via => :post
      match '/ios/change_password' => 'ios#change_password', :via => :post
      match '/ios/forgot_password' => 'ios#forgot_password', :via => :post
      match '/ios/about_us' => 'ios#about_us', :via => :post
      match '/ios/contact_us' => 'ios#contact_us', :via => :post
      match '/ios/get_donations' => 'ios#get_donations', :via => :post
      match '/ios/approve_picture' => 'ios#approve_picture', :via => :post
      match '/ios/approve_feedback' => 'ios#approve_feedback', :via => :post
      match '/ios/get_all_requests' => 'ios#get_all_requests', :via => :post
      match '/ios/get_all_sessions' => 'ios#get_all_sessions', :via => :post
    end
    match "*path" , to: "base#catch_404", via: :all
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
