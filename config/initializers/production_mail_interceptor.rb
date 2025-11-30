# # Redirect outgoing emails to a test inbox while we're validating production notifications.
# if Rails.env.production?
#   class ProductionTestMailInterceptor
#     def self.delivering_email(message)
#       original_to  = Array(message.to)
#       original_cc  = Array(message.cc)
#       original_bcc = Array(message.bcc)

#       message.to = ["andre.salatalima@gmail.com"]
#       # Preserve original recipients in headers to aid debugging.
#       message.header["X-Original-To"] = original_to.join(", ") if original_to.any?
#       message.header["X-Original-Cc"] = original_cc.join(", ") if original_cc.any?
#       message.header["X-Original-Bcc"] = original_bcc.join(", ") if original_bcc.any?
#       message.cc = message.bcc = nil
#     end
#   end

#   ActionMailer::Base.register_interceptor(ProductionTestMailInterceptor)
# end
