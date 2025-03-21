// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import CotacaoController from "controllers/cotacao_controller"
import DatePickerController from "controllers/date_picker_controller"
import ProductSearchController from "controllers/product_search_controller"
import AvailabilityController from "controllers/availability_controller"
import PriceAlertController from "controllers/price_alert_controller"
import UploadModalController from "controllers/upload_modal_controller"
import ApprovalController from "controllers/approval_controller"
import CustomNameController from "controllers/custom_name_controller"

const application = Application.start()

application.register("cotacao", CotacaoController)
application.register("date-picker", DatePickerController)
application.register("product-search", ProductSearchController)
application.register("availability", AvailabilityController)
application.register("price-alert", PriceAlertController)
application.register("upload-modal", UploadModalController)
application.register("approval", ApprovalController)
application.register("custom-name", CustomNameController)
