import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["calendar", "frame", "dateLabel", "mobileList"]
  static values = {
    timeSlotsUrl: String,
    initialDate: String
  }

  connect() {
    this.selectedDate = this.initialDateValue ? new Date(this.initialDateValue) : new Date()
    this.currentMonth = new Date(this.selectedDate.getFullYear(), this.selectedDate.getMonth(), 1)

    if (this.hasFrameTarget) {
      this._frameLoaded = this.frameLoaded.bind(this)
      this.frameTarget.addEventListener("turbo:frame-load", this._frameLoaded)
    }

    this.renderCalendar()
    this.renderMobileList()
    this.updateDateLabel()
  }

  disconnect() {
    if (this.hasFrameTarget && this._frameLoaded) {
      this.frameTarget.removeEventListener("turbo:frame-load", this._frameLoaded)
    }
  }

  previousMonth(event) {
    event.preventDefault()
    this.currentMonth.setMonth(this.currentMonth.getMonth() - 1)
    this.renderCalendar()
  }

  nextMonth(event) {
    event.preventDefault()
    this.currentMonth.setMonth(this.currentMonth.getMonth() + 1)
    this.renderCalendar()
  }

  selectDateFromButton(event) {
    event.preventDefault()
    const value = event.currentTarget.dataset.date
    if (!value) return

    this.selectDate(new Date(value))
  }

  selectDate(date) {
    this.selectedDate = new Date(date.getFullYear(), date.getMonth(), date.getDate())
    this.currentMonth = new Date(this.selectedDate.getFullYear(), this.selectedDate.getMonth(), 1)
    this.renderCalendar()
    this.renderMobileList()
    this.updateDateLabel()
    this.loadSlots()
  }

  loadSlots() {
    if (!this.hasFrameTarget) return

    const dateString = this.formatDate(this.selectedDate)
    const url = `${this.timeSlotsUrlValue}?date=${dateString}`
    if (this.frameTarget.getAttribute("src") === url) {
      return
    }

    // Clear the src first to prevent conflicting requests
    this.frameTarget.removeAttribute("src")
    
    // Update turbo-frame ID to match the new date
    this.updateFrameId()
    this.showSkeleton()
    
    // Set the new src to trigger the request with the correct frame ID
    this.frameTarget.setAttribute("src", url)
  }

  updateFrameId() {
    if (!this.hasFrameTarget) return
    
    // Generate the new frame ID that matches what Rails will generate
    const doctorId = this.getDoctorIdFromFrame()
    const formattedDate = this.formatDateForDomId(this.selectedDate)
    const newId = `[:time_slots, ${formattedDate}]_doctor_${doctorId}`
    
    const oldId = this.frameTarget.getAttribute("id")
    console.log(`Updating frame ID from "${oldId}" to "${newId}"`)
    
    this.frameTarget.setAttribute("id", newId)
  }

  getDoctorIdFromFrame() {
    // Extract doctor ID from current frame ID
    const currentId = this.frameTarget.getAttribute("id")
    const match = currentId.match(/_doctor_(\d+)$/)
    return match ? match[1] : null
  }

  formatDateForDomId(date) {
    // Format date to match Rails' Date#to_s format exactly (e.g., "Fri, 14 Nov 2025")
    const weekday = date.toLocaleDateString('en-US', { weekday: 'short' })
    const day = date.getDate()
    const month = date.toLocaleDateString('en-US', { month: 'short' })
    const year = date.getFullYear()
    
    return `${weekday}, ${day} ${month} ${year}`
  }

  frameLoaded() {
    this.frameTarget.classList.remove("opacity-50")
  }

  scrollToSlots(event) {
    if (event) {
      event.preventDefault()
    }

    if (this.hasFrameTarget) {
      this.frameTarget.scrollIntoView({ behavior: "smooth", block: "start" })
    }
  }

  renderCalendar() {
    if (!this.hasCalendarTarget) return

    const month = this.currentMonth.getMonth()
    const year = this.currentMonth.getFullYear()
    const monthStart = new Date(year, month, 1)
    const monthLabel = monthStart.toLocaleDateString(undefined, { month: "long", year: "numeric" })
    const daysInMonth = new Date(year, month + 1, 0).getDate()
    const startDay = monthStart.getDay()

    const header = `
      <div class="flex items-center justify-between">
        <button data-action="patient-calendar#previousMonth" class="inline-flex h-9 w-9 items-center justify-center rounded-full border border-slate-200 text-slate-600 hover:border-blue-500 hover:text-blue-600">
          &larr;
        </button>
        <div class="text-sm font-semibold text-slate-700">${monthLabel}</div>
        <button data-action="patient-calendar#nextMonth" class="inline-flex h-9 w-9 items-center justify-center rounded-full border border-slate-200 text-slate-600 hover:border-blue-500 hover:text-blue-600">
          &rarr;
        </button>
      </div>
    `

    const dayNames = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    const dayHeader = `
      <div class="mt-4 grid grid-cols-7 gap-1 text-center text-xs font-semibold uppercase tracking-wide text-slate-400">
        ${dayNames.map((day) => `<span>${day}</span>`).join("")}
      </div>
    `

    const days = []
    for (let i = 0; i < startDay; i += 1) {
      days.push('<div class="h-10 rounded-lg"></div>')
    }

    for (let day = 1; day <= daysInMonth; day += 1) {
      const current = new Date(year, month, day)
      const iso = this.formatDate(current)
      const isSelected = this.isSameDay(current, this.selectedDate)
      const isToday = this.isSameDay(current, new Date())

      let classes = "h-10 rounded-lg border text-sm font-medium transition flex items-center justify-center"
      if (isSelected) {
        classes += " border-blue-500 bg-blue-600 text-white"
      } else if (isToday) {
        classes += " border-blue-200 bg-blue-50 text-blue-600"
      } else {
        classes += " border-transparent text-slate-600 hover:border-blue-200 hover:bg-blue-50"
      }

      days.push(`<button type="button" data-date="${iso}" data-action="patient-calendar#selectDateFromButton" class="${classes}">${day}</button>`)
    }

    const grid = `<div class="mt-2 grid grid-cols-7 gap-1 text-center">${days.join("")}</div>`

    this.calendarTarget.innerHTML = header + dayHeader + grid
  }

  renderMobileList() {
    if (!this.hasMobileListTarget) return

    const start = new Date()
    const days = []
    for (let i = 0; i < 14; i += 1) {
      const current = new Date(start)
      current.setDate(start.getDate() + i)
      const iso = this.formatDate(current)
      const isSelected = this.isSameDay(current, this.selectedDate)
      const isToday = this.isSameDay(current, new Date())

      let classes = "flex-1 rounded-full border px-3 py-2 text-center text-xs font-semibold transition"
      if (isSelected) {
        classes += " border-blue-500 bg-blue-600 text-white"
      } else if (isToday) {
        classes += " border-blue-200 bg-blue-50 text-blue-600"
      } else {
        classes += " border-slate-200 text-slate-600 hover:border-blue-200 hover:bg-blue-50"
      }

      days.push(`<button type="button" data-date="${iso}" data-action="patient-calendar#selectDateFromButton" class="${classes}">
        <span class="block text-[10px] uppercase tracking-wide">${current.toLocaleDateString(undefined, { weekday: "short" })}</span>
        <span class="block text-sm">${current.getDate()}</span>
      </button>`)
    }

    this.mobileListTarget.innerHTML = days.join("")
  }

  updateDateLabel() {
    if (!this.hasDateLabelTarget) return

    const formatted = this.selectedDate.toLocaleDateString(undefined, {
      weekday: "long",
      month: "long",
      day: "numeric"
    })

    this.dateLabelTarget.textContent = formatted
  }

  showSkeleton() {
    this.frameTarget.classList.add("opacity-50")
    this.frameTarget.innerHTML = `
      <div class="space-y-3">
        ${Array.from({ length: 3 })
          .map(
            () =>
              '<div class="h-20 animate-pulse rounded-xl border border-slate-200 bg-slate-100"></div>'
          )
          .join("")}
      </div>
    `
  }

  formatDate(date) {
    const month = `${date.getMonth() + 1}`.padStart(2, "0")
    const day = `${date.getDate()}`.padStart(2, "0")
    return `${date.getFullYear()}-${month}-${day}`
  }

  isSameDay(a, b) {
    return a.getFullYear() === b.getFullYear() && a.getMonth() === b.getMonth() && a.getDate() === b.getDate()
  }
}
