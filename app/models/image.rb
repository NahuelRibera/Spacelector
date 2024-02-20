class Image < ApplicationRecord
  belongs_to :space
  has_many :compartments, dependent: :destroy
  has_one_attached :file
  accepts_nested_attributes_for :compartments
  validates :title, presence: true
end
