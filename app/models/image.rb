class Image < ApplicationRecord
  belongs_to :space
  has_many :compartments
  has_one_attached :file 
  validates :title, presence: true
end
