class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  has_attached_file :image, styles: { medium: "300x300>", thumb: "100x100#" }
  
  validates_attachment_content_type :image, content_type: /\Aimage\/.*\Z/
 
  scope :coordinators, -> { where(employee_type: 'coordinator') }
  scope :implementers, -> { where(employee_type: 'implementers') }
  scope :volunteers, -> { where(employee_type: 'volunteer') }
  scope :trainers, -> { where(employee_type: 'trainer') }

  belongs_to :company

  has_many :implementer_requests, dependent: :destroy


  has_many :programs, through: :implementer_requests
  has_many :lessons, through: :implementer_requests, dependent: :destroy

  has_one :api_key, dependent: :destroy

  after_create :create_api_key
  def ensure_authentication_token!
    if self.api_key.nil?
      ApiKey.create :user => self
    end
  end

   #methods
  def admin?
    self.admin == true
  end

  private
  def create_api_key
    ApiKey.create :user => self
  end
end
