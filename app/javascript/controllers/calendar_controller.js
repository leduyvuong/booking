import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["calendar", "modal", "modalTitle", "modalSubtitle", "modalBody"]
  static values = { events: Array }

  connect() {
    this.renderCalendar()
  }

  disconnect() {
    if (this.calendar) {
      this.calendar.destroy()
      this.calendar = null
    }
  }

  renderCalendar() {
    if (!window.FullCalendar) {
      window.setTimeout(() => this.renderCalendar(), 100)
      return
    }

    let events = []
    try {
      events = this.eventsValue || []
      console.log("Events loaded:", events.length)
    } catch (e) {
      console.error("Error parsing events:", e)
      events = []
    }

    this.calendar = new window.FullCalendar.Calendar(this.calendarTarget, {
      initialView: "dayGridMonth",
      headerToolbar: {
        left: "prev,next today",
        center: "title",
        right: "dayGridMonth,timeGridWeek,timeGridDay"
      },
      events: events,
      eventClick: this.handleEventClick.bind(this),
      height: "auto"
    })

    this.calendar.render()
  }

  handleEventClick(info) {
    const props = info.event.extendedProps || {}
    const start = info.event.start
    const end = info.event.end

    this.modalTitleTarget.textContent = `${props.doctorName || "Time Slot"}`
    this.modalSubtitleTarget.textContent = `${this.formatRange(start, end)} · ${props.bookedCount}/${props.maxPatients} booked`

    this.modalBodyTarget.innerHTML = ""
    const appointments = props.appointments || []

    if (appointments.length === 0) {
      this.modalBodyTarget.insertAdjacentHTML(
        "beforeend",
        '<p class="text-sm text-slate-500">No appointments booked for this slot.</p>'
      )
    } else {
      const list = document.createElement("ul")
      list.className = "divide-y divide-slate-200"

      appointments.forEach((appointment) => {
        const item = document.createElement("li")
        item.className = "py-2"
        item.innerHTML = `
          <div class="flex items-center justify-between">
            <div>
              <p class="text-sm font-semibold text-slate-700">${appointment.patient_name}</p>
              <p class="text-xs text-slate-500">Booking #${appointment.booking_number}</p>
            </div>
            <span class="inline-flex items-center rounded-full px-2.5 py-1 text-xs font-medium ${this.statusBadgeClass(appointment.status)}">
              ${appointment.status}
            </span>
          </div>
          ${appointment.notes ? `<p class="mt-2 text-xs text-slate-500">${appointment.notes}</p>` : ""}
        `
        list.appendChild(item)
      })

      this.modalBodyTarget.appendChild(list)
    }

    this.openModal()
  }

  openModal() {
    this.modalTarget.classList.remove("hidden")
  }

  closeModal(event) {
    if (event) {
      event.preventDefault()
    }
    this.modalTarget.classList.add("hidden")
  }

  stop(event) {
    event.stopPropagation()
  }

  formatRange(start, end) {
    if (!start || !end) {
      return ""
    }

    const startDate = start.toLocaleDateString(undefined, { weekday: "short", month: "short", day: "numeric" })
    const startTime = start.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })
    const endTime = end.toLocaleTimeString(undefined, { hour: "2-digit", minute: "2-digit" })

    return `${startDate} · ${startTime} – ${endTime}`
  }

  statusBadgeClass(status) {
    switch (status) {
      case "confirmed":
        return "bg-emerald-100 text-emerald-700"
      case "pending":
        return "bg-amber-100 text-amber-700"
      case "cancelled":
        return "bg-rose-100 text-rose-700"
      default:
        return "bg-slate-100 text-slate-600"
    }
  }
}
