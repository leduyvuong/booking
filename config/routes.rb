# frozen_string_literal: true

Rails.application.routes.draw do
  devise_for :users

  root "home#index"

  resources :clinics, only: %i[index show]
  resources :doctors, only: %i[index show] do
    resources :time_slots, only: %i[index]
  end
  resources :appointments, only: %i[index show create update]
end
