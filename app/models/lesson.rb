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
  end
end
