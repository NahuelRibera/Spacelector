class ConvertHeicToJpegJob < ApplicationJob
  queue_as :default

  def perform(blob_id)
    blob = ActiveStorage::Blob.find(blob_id)
    return unless blob.content_type == 'image/heic'

    variant = blob.variant(convert: 'jpg').processed
    new_blob = ActiveStorage::Blob.create_and_upload!(
      io: variant.service.download(variant.key),
      filename: "#{blob.filename.base}.jpg",
      content_type: 'image/jpeg'
    )

    # Replace the old blob with the new
    attacher = ActiveStorage::Attachment.find_by(blob_id: blob.id)
    attacher.update!(blob: new_blob)

    # Optionally clean up the old blob
    blob.purge_later
  end
end
