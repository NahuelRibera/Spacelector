namespace :spacelector do
  desc "Remove Image/Compartment/ObjectInfo rows that can never render again: blobs still " \
       "pointing at the old project's S3 bucket ('amazon' service, matched by name only, never " \
       "contacted), or blobs whose file is missing from local/test disk storage. Spaces and " \
       "subspaces are preserved."
  task cleanup_legacy_images: :environment do
    amazon_blob_ids = ActiveStorage::Blob.where(service_name: "amazon").pluck(:id)

    missing_local_blob_ids = ActiveStorage::Blob.where.not(service_name: "amazon").filter_map do |blob|
      blob.id unless blob.service.exist?(blob.key) # local filesystem check only, never hits a remote service
    end

    legacy_blob_ids = (amazon_blob_ids + missing_local_blob_ids).uniq

    if legacy_blob_ids.empty?
      puts "No legacy or broken blobs found. Nothing to do."
      next
    end

    legacy_image_ids = ActiveStorage::Attachment
                          .where(record_type: "Image", blob_id: legacy_blob_ids)
                          .pluck(:record_id)
                          .uniq

    if legacy_image_ids.empty?
      puts "No images reference the legacy/broken blobs. Nothing to do."
      next
    end

    compartment_ids = Compartment.where(image_id: legacy_image_ids).pluck(:id)

    # delete_all everywhere on purpose: it skips ActiveStorage's purge callbacks, so this
    # never issues a delete request against a remote bucket (relevant for the 'amazon' blobs).
    object_info_count = ObjectInfo.where(compartment_id: compartment_ids).delete_all
    compartment_count = Compartment.where(id: compartment_ids).delete_all
    attachment_count = ActiveStorage::Attachment.where(record_type: "Image", record_id: legacy_image_ids).delete_all
    image_count = Image.where(id: legacy_image_ids).delete_all
    orphaned_blob_count = ActiveStorage::Blob
                             .where(id: legacy_blob_ids)
                             .where.not(id: ActiveStorage::Attachment.select(:blob_id))
                             .delete_all

    puts "Removed #{image_count} legacy image(s), #{compartment_count} compartment(s), " \
         "#{object_info_count} annotation(s), #{attachment_count} attachment row(s), " \
         "#{orphaned_blob_count} orphaned blob row(s)."
    puts "Spaces and subspaces were left untouched. No requests were made to any remote storage service."
  end
end
