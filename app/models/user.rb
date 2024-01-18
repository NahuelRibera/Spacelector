class User < ApplicationRecord
has_many :spaces
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
