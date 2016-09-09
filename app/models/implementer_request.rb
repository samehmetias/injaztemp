class ImplementerRequest < ActiveRecord::Base
  belongs_to :school
  belongs_to :program
  belongs_to :user
  
  has_many :lessons, dependent: :destroy
  
  scope :accepted, -> { where(status: 'YES') }		
  scope :pending, -> { where(status: 'pending') }		
  scope :refused, -> { where(status: 'NO') }
  
  #methods
  def accept
    self.status = 'YES'
    @i = 0
    @d = self.start_date
    st = self.start_time
    et = self.end_time
    @s = self.program.duration
    while @i < @s do
      @l = Lesson.new ()
      @l.date = @d + (@i*2).minutes
      @l.name = 'Session '+(@i+1).to_s
      @l.start_time = st
      @l.end_time = et
      self.lessons << @l
      remindUser("You have a session tomorrow!",self.user.id,@l.date)
      @i = @i+1
    end
  self.save
  end
  
  def refuse
    self.status = 'NO'
    self.save
    u_id = User.where(admin: true).first.id
    notifyUser(self.user.name+' working at '+self.user.company.name+' rejected '+self.school.name+ ' on '+self.start_date.strftime('%A, %d.%m.%y'),u_id)
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

  def remindUser(message,u_id,di)
    apn = ApnHelper::Apn.new
    id = u_id
    u = Phone.where(user_id: id).first
    if (!(u.nil?))
      token = u.token
      puts '++++++++++remindUser+++++++++++++'
        puts token
      puts '++++++++++remindUser+++++++++++++'
      # apn.delay(:priority => 1).sendAlert(token, "INJAZ Egypt",message,"",true)
      if(!(self.status=='NO'))
        apn.delay(:priority => 1, :run_at => di - 1.days  - 2.hours, :queue => self.id.to_s).sendAlert(token, "INJAZ Egypt",message,"",true)
      end
      # render :text => '1'
    end
  end

  def getCoordinators
    s = self.school
    p = self.program
    d = self.start_date

    #@coor_imp = ImplementerRequest.where(school_id = s.id)
    # @e = User.joins(@coor_imp).where()
    if(self.user.employee_type != 'Coordinator')
      coor_imp = ImplementerRequest.includes(:user).where(school: s, program: p, start_date: d,:users => {employee_type: 'Coordinator' } ).all
    end
   # @coor_imp = ImplementerRequest.where('School = ? and Program = ? and start_data = ?', s,p,d)
    # @coor_imp.each do |company|
    #  puts company.User.name
    # end
  end
end
