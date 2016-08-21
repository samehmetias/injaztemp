class Program < ActiveRecord::Base
  has_many :Implementer_requests, dependent: :destroy
end
