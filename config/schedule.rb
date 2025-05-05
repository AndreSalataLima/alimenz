set :output, "log/cron.log"
env :PATH, ENV['PATH']

every 1.day, at: '1:00 am' do
  runner "Quotation.expire_expired_quotations"
end
