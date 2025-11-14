# Clinic Booking

A Rails 7 clinic appointment booking system backed by PostgreSQL, Tailwind CSS, Turbo and Stimulus.

## Setup

1. Install Ruby 3.4.4 and PostgreSQL.
2. Install gems: `bundle install`.
3. Configure `config/database.yml` credentials if needed.
4. Prepare the database: `bundle exec rails db:setup`.
5. Start the application: `bin/dev`.

## Features

- Clinics with doctors and daily schedules.
- Doctors manage time slots with availability and capacity.
- Patients can book appointments with concurrency-safe transactions.
- Devise authentication with patient and admin roles.
- Tailwind-powered UI with Turbo/Stimulus front-end.

## Seeds

`rails db:seed` creates:
- One sample clinic with three doctors.
- Time slots for the next seven days.
- Admin user (`admin@clinic.test` / `Password1!`).
- Patient user (`patient@clinic.test` / `Password1!`).
