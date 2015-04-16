Rails.application.routes.draw do
  devise_for :users
  get 'welcome', to: 'static_pages#welcome'
  get 'about', to: 'static_pages#about'

  get 'references/index'
  get 'references/new'
  get 'references/destroy'

  get 'nodes/new', as: :node_new
  get 'nodes/search', to: 'nodes#search', as: :nodes_search
  get 'nodes/instant_new_for/:id', to: 'nodes#instant_new_for'
  get 'nodes/edit/:id', to: 'nodes#edit', as: :node_edit
  get 'nodes/:id', to: 'nodes#show', as: :node
  delete 'nodes/:id', to: 'nodes#destroy'
  get 'nodes', to: 'nodes#index', as: :nodes
  post 'nodes', to: 'nodes#create'
  patch 'nodes/:id', to: 'nodes#update'

  post 'tjax/convert'

  root 'static_pages#welcome'
end
