class ConvertHeicToJpegJob < ApplicationJob
  queue_as :default

  def perform(blob_id)
    blob = ActiveStorage::Blob.find(blob_id)
    return unless blob.content_type == 'image/heic'

    downloaded_blob = Tempfile.new
    downloaded_blob.binmode
    downloaded_blob.write(blob.download)
    downloaded_blob.rewind

    require "image_processing/mini_magick"

    processed_image = ImageProcessing::MiniMagick
                        .source(downloaded_blob)
                        .convert("jpg")
                        .call

    new_blob = ActiveStorage::Blob.create_and_upload!(
      io: processed_image,
      filename: "#{blob.filename.base}.jpg",
      content_type: 'image/jpeg'
    )

    attacher = ActiveStorage::Attachment.find_by(blob_id: blob.id)
    attacher.update!(blob: new_blob)

    blob.purge_later
    downloaded_blob.close
    downloaded_blob.unlink
  end
end
