class Compartment < ApplicationRecord
  belongs_to :image
  has_many :object_infos, dependent: :destroy
end
