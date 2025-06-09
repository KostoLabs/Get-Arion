class ApplicationMailer < ActionMailer::Base
  default from: email_address_with_name(ENV.fetch("EMAIL_SENDER", "hello@getarion.io"), "Arion")
  layout "mailer"
end
