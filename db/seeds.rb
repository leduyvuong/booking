# frozen_string_literal: true

puts "Seeding clinic appointment data..."

Appointment.destroy_all
TimeSlot.destroy_all
Doctor.destroy_all
Clinic.destroy_all
User.destroy_all

clinic = Clinic.create!(
  name: "Downtown Health Clinic",
  address: "123 Main Street",
  phone: "555-0100",
  email: "info@downtownhealth.test",
  opening_hours: {
    monday: "08:00-18:00",
    tuesday: "08:00-18:00",
    wednesday: "08:00-18:00",
    thursday: "08:00-18:00",
    friday: "08:00-17:00",
    saturday: "09:00-13:00",
    sunday: "Closed"
  }
)

doctors = [
  { name: "Dr. Alice Carter", specialty: "Family Medicine", bio: "Experienced family physician with a focus on preventive care." },
  { name: "Dr. Benjamin Hayes", specialty: "Dermatology", bio: "Specializes in skin health and outpatient procedures." },
  { name: "Dr. Sofia Nguyen", specialty: "Pediatrics", bio: "Compassionate pediatrician caring for children of all ages." }
].map do |attrs|
  clinic.doctors.create!(attrs.merge(avatar_url: "https://example.com/avatar.png"))
end

admin = User.create!(email: "admin@clinic.test", password: "Password1!", role: :admin)
patient = User.create!(email: "patient@clinic.test", password: "Password1!", role: :patient)

puts "Created admin #{admin.email} and patient #{patient.email}"

start_date = Date.current
end_date = start_date + 6.days

(start_date..end_date).each do |date|
  doctors.each do |doctor|
    [[9, 0], [10, 0], [11, 0], [13, 0], [14, 0]].each do |hour, minute|
      start_time = Time.zone.parse("#{hour}:#{minute.to_s.rjust(2, '0')}")
      end_time = start_time + 45.minutes
      doctor.time_slots.create!(
        date: date,
        start_time: start_time.strftime("%H:%M:%S"),
        end_time: end_time.strftime("%H:%M:%S"),
        max_patients: 4,
        status: :available
      )
    end
  end
end

puts "Created #{TimeSlot.count} time slots"

puts "Seeding complete."
