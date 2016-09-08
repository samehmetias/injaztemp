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
  end
end
