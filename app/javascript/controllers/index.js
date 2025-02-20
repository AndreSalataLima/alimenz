// app/javascript/controllers/index.js
import { Application } from "@hotwired/stimulus"
import CotacaoController from "controllers/cotacao_controller"
import DatePickerController from "controllers/date_picker_controller"
import ProductSearchController from "controllers/product_search_controller"

const application = Application.start()

application.register("cotacao", CotacaoController)
application.register("date-picker", DatePickerController)
application.register("product-search", ProductSearchController)
