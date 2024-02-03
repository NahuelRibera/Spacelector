class Image < ApplicationRecord
  belongs_to :space
  has_one_attached :file
  # Remove the title validation if you're not using it
  # validates :title, presence: true
end
