class Lesson < ActiveRecord::Base
  belongs_to :implementer_request
  
  #methods
def accept
	self.status = 'YES'
	self.save
end
  
  def refuse
    self.status = 'NO'
  	self.save
  	u_id = User.where(admin: true).first.id
    notifyUser(self.implementer_request.user.name+' working at '+self.implementer_request.user.company.name+' rejected '+self.name+' at '+self.implementer_request.school.name+ ' on '+self.date.strftime('%A, %d.%m.%y'),u_id)
    focalpoints = User.where(employee_type: 'Focal Point').where(company_id: self.implementer_request.user.company.id)
    focalpoints.each do |e|
      notifyUser(self.implementer_request.user.name+' working at '+self.implementer_request.user.company.name+' rejected '+self.name+' at '+self.implementer_request.school.name+ ' on '+self.date.strftime('%A, %d.%m.%y'),e.id)
    end
  end
  def notifyUser(message,u_id)
    apn = ApnHelper::Apn.new
    id = u_id
    u = Phone.where(user_id: id).first
    if (!(u.nil?))
      token = u.token
      puts '++++++++++NotifyUser+++++++++++++'
        puts token
      puts '++++++++++NotifyUser+++++++++++++'
      apn.delay(:priority => 1).sendAlert(token, "INJAZ Egypt",message,"",true)
      # render :text => '1'
    end
  end
end
