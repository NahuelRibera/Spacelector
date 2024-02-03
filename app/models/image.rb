# app/models/image.rb
class Image < ApplicationRecord
  belongs_to :space
  has_one_attached :file
  validates :title, presence: true
end
