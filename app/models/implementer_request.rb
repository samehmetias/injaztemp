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
    @s = self.program.duration
    while @i < @s do
      @l = Lesson.new ()
      @l.date = @d + (@i*7).days
      @l.name = 'Session '+(@i+1).to_s
      self.lessons << @l
      @i = @i+1
    end
  self.save
  end
  
  def refuse
    self.status = 'NO'
    self.save
  end
end
