# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :clinics, only: %i[index show]
  resources :doctors, only: %i[index show] do
    resources :time_slots, only: %i[index]
  end
  resources :appointments, only: %i[index show create update]

  namespace :admin do
    root to: "dashboard#index"

    get "dashboard", to: "dashboard#index"
    resources :doctors
    resources :time_slots do
      collection do
        get :bulk_new
        post :bulk_preview
        post :bulk_create
      end
    end
    resources :appointments, only: %i[index show update] do
      collection do
        post :bulk_update
      end
      member do
        patch :cancel
      end
    end
    resource :calendar, only: :show
  end
end
