class UserMailer < ActionMailer::Base
  default from: "Oshtoora<no-reply@oshtoora.com>"

  def welcome_email(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome')
  end

end