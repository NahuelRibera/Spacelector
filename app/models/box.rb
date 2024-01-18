class Box < ApplicationRecord
  belongs_to :image
  has_one :info, dependent: :destroy
end
