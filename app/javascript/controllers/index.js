import { application } from "./application"

import BookingController from "./booking_controller"
import CalendarController from "./calendar_controller"
import ToastController from "./toast_controller"
import SelectAllController from "./select_all_controller"
import CancelModalController from "./cancel_modal_controller"

application.register("booking", BookingController)
application.register("calendar", CalendarController)
application.register("toast", ToastController)
application.register("select-all", SelectAllController)
application.register("cancel-modal", CancelModalController)
