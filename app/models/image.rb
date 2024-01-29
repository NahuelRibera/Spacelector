class Image < ApplicationRecord
  belongs_to :space
  has_many :boxes, dependent: :destroy
  has_one_attached :file
end
