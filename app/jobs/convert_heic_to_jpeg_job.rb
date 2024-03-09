class ConvertHeicToJpegJob < ApplicationJob
  queue_as :default

  def perform(blob_id)
    blob = ActiveStorage::Blob.find(blob_id)
    return unless blob.content_type == 'image/heic'

    # Download the original HEIC file
    downloaded_blob = Tempfile.new
    downloaded_blob.binmode
    downloaded_blob.write(blob.download)
    downloaded_blob.rewind

    require "image_processing/mini_magick"

    # Convert the image to JPEG
    processed_image = ImageProcessing::MiniMagick
                        .source(downloaded_blob)
                        .convert("jpg")
                        .call

    # Create a new blob for the converted image
    new_blob = ActiveStorage::Blob.create_and_upload!(
      io: processed_image,
      filename: "#{blob.filename.base}.jpg",
      content_type: 'image/jpeg'
    )

    # Replace the old blob with the new one
    attacher = ActiveStorage::Attachment.find_by(blob_id: blob.id)
    attacher.update!(blob: new_blob)

    # Optionally clean up the old blob and temporary files
    blob.purge_later
    downloaded_blob.close
    downloaded_blob.unlink
  end
end
