import { application } from "./application"

import BookingController from "./booking_controller"
import BookingModalController from "./booking_modal_controller"
import CalendarController from "./calendar_controller"
import PatientCalendarController from "./patient_calendar_controller"
import LoadingButtonController from "./loading_button_controller"
import ToastController from "./toast_controller"
import SelectAllController from "./select_all_controller"
import CancelModalController from "./cancel_modal_controller"

application.register("booking", BookingController)
application.register("booking-modal", BookingModalController)
application.register("calendar", CalendarController)
application.register("patient-calendar", PatientCalendarController)
application.register("loading-button", LoadingButtonController)
application.register("toast", ToastController)
application.register("select-all", SelectAllController)
application.register("cancel-modal", CancelModalController)
