// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import CotacaoController from "controllers/cotacao_controller"
import DatePickerController from "controllers/date_picker_controller"
import AvailabilityController from "controllers/availability_controller"
import PriceAlertController from "controllers/price_alert_controller"
import UploadModalController from "controllers/upload_modal_controller"
import ApprovalController from "controllers/approval_controller"
import CustomNameController from "controllers/custom_name_controller"
import QuotationResponseController from "controllers/quotation_response_controller"
import UpdateTotalController from "controllers/update_total_controller"
import AutoSubmitController from "controllers/auto_submit_controller"
import AdminUpdateTotalController from "controllers/admin_update_total_controller"
import CommissionModalController from "controllers/commission_modal_controller"


const application = Application.start()

application.register("cotacao", CotacaoController)
application.register("date-picker", DatePickerController)
application.register("availability", AvailabilityController)
application.register("price-alert", PriceAlertController)
application.register("upload-modal", UploadModalController)
application.register("approval", ApprovalController)
application.register("custom-name", CustomNameController)
application.register("quotation-response", QuotationResponseController)
application.register("update-total", UpdateTotalController)
application.register("auto-submit", AutoSubmitController)
application.register("admin-update-total", AdminUpdateTotalController)
application.register("commission-modal", CommissionModalController)
