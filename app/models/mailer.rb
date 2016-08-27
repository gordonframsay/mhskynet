class Mailer < ActionMailer::Base

 layout 'mailer'

  # NOTE: This is a special method for parsing incoming emails.
  def receive(email)
   return email
  end

  def error_mailer(error_message)
    @subject                            = "Error on MH"
    @from                               = 'gordon@mhsky.net'
    @recipients                         = 'gordon@mhsky.net'
    @error_message			= error_message
    mailer_setup
    mail(to: @recipients, from: @from, reply_to: @reply_to, cc: @cc, bcc: @bcc, subject: @subject)
  end

 private

  def mailer_setup
   @subject = "[test] "+@subject if (Rails.env.to_s == "development")
   @mailer_name = caller_locations(1,1)[0].label
  end

end
