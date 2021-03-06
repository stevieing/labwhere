Rails.application.routes.draw do

  concern :change_status do
    patch 'activate', on: :member
    patch 'deactivate', on: :member
  end

  concern :auditable do |options|
    scope module: options[:parent] do
      resources :audits, only: [:index]
    end
  end

  resources :location_types do
    scope module: :location_types do
      resources :locations, only: [:index]
    end

    concerns :auditable, parent: :location_types
  end

  resources :locations do 
    
    resources :prints, only: [:new, :create]

    concerns :change_status
    concerns :auditable, parent: :locations
    scope module: :locations do
      resources :children, only: [:index]
      resources :labwares, only: [:index]
    end

  end

  resources :labwares, only: [:show] do
    concerns :auditable, parent: :labwares
  end

  resources :scans, only: [:new, :create]

  resources :searches, only: [:new, :create, :show]

  resources :users do
    concerns :auditable, parent: :users
    concerns :change_status
  end

  resources :teams do
    concerns :auditable, parent: :teams
  end

  resources :printers do
    concerns :auditable, parent: :printers
  end
  
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  root 'scans#new'

  namespace :api do

    resources :locations, param: :barcode, except: [:destroy] do
      scope module: :locations do
        resources :labwares, only: [:index]
        resources :children, only: [:index]
        resources :coordinates, only: [:show], param: :available
      end

      concerns :auditable, parent: :locations
      
    end

    resources :location_types, except: [:destroy] do
      scope module: :location_types do
        resources :locations, only: [:index]
      end

      concerns :auditable, parent: :location_types

    end

    resources :scans, only: [:create]

    resources :labwares, param: :barcode, only: [:show] do
      concerns :auditable, parent: :labwares
    end

    resources :searches, only: [:create]

  end

  get 'api/docs', to: 'api/docs#index'
  post 'api/labwares/searches', to: 'api/labwares/searches#create'

  match '(errors)/:status', to: 'errors#show', constraints: {status: /\d{3}/}, via: :all

  match 'test_exception_notifier', controller: 'application', action: 'test_exception_notifier', via: :get

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
