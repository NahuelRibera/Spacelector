class Image < ApplicationRecord
  belongs_to :space
  has_many :compartments, dependent: :destroy
  has_one_attached :file
  accepts_nested_attributes_for :compartments
  validates :title, presence: true
  after_create_commit :convert_heic_to_jpeg

  def converted?
    file.attached? && (file.content_type != 'image/heic' || file.blob.filename.extension_without_delimiter != 'heic')
  end

  private

  def convert_heic_to_jpeg
    return unless file.attached? && file.content_type == 'image/heic'
    ConvertHeicToJpegJob.perform_later(file.blob.id)
  end
end
