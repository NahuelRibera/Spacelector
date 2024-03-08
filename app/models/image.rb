class Image < ApplicationRecord
  belongs_to :space
  has_many :compartments, dependent: :destroy
  has_one_attached :file
  accepts_nested_attributes_for :compartments
  validates :title, presence: true
  after_create_commit :convert_heic_to_jpeg

  private

  # Convert HEIC image to JPEG
  def convert_heic_to_jpeg
    return unless file.attached? && file.content_type == 'image/heic'
    # Perform the conversion in a background job for performance
    ConvertHeicToJpegJob.perform_later(file.blob.id)
  end
end
