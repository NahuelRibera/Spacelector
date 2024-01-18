class Space < ApplicationRecord
  belongs_to :user
  has_many :images, dependent: :destroy
  has_many :child_spaces, class_name: 'Space', foreign_key: 'parent_space_id', dependent: :destroy
  belongs_to :parent_space, class_name: 'Space', optional: true, foreign_key: 'parent_space_id'
end
