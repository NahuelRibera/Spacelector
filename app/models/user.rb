class User < ApplicationRecord
has_one_attached :profile_photo
has_many :spaces
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
