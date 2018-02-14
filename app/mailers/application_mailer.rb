class ApplicationMailer < ActionMailer::Base
  default from: 'Standard File <hello@yourdomain.org>'
  layout 'mailer'
end
