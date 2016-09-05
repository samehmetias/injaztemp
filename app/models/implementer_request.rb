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
      @l.date = @d + (@i*7).days
      @l.name = 'Session '+(@i+1).to_s
      @l.start_time = st
      @l.end_time = et
      self.lessons << @l
      @i = @i+1
    end
  self.save
  end
  
  def refuse
    self.status = 'NO'
    self.save
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
