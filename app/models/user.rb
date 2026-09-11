class User < ApplicationRecord
  include SubscriptionConcern
  has_one_attached :profile_photo
  has_many :spaces
    devise :database_authenticatable, :registerable,
          :recoverable, :rememberable, :validatable,
          :omniauthable, omniauth_providers: [:google_oauth2]
  pay_customer stripe_attributes: :stripe_attributes

  def storage_used_bytes
    Image.joins(:space)
         .where(spaces: { user_id: id })
         .joins("INNER JOIN active_storage_attachments ON active_storage_attachments.record_type = 'Image' AND active_storage_attachments.record_id = images.id")
         .joins("INNER JOIN active_storage_blobs ON active_storage_blobs.id = active_storage_attachments.blob_id")
         .sum("active_storage_blobs.byte_size")
  end

  def self.from_omniauth(auth)
    where(provider: auth.provider, uid: auth.uid).first_or_create do |user|
      user.email = auth.info.email
      user.password = Devise.friendly_token[0, 20]
      user.full_name = auth.info.name
      user.avatar_url = auth.info.image
    end
  end

  def stripe_attributes(pay_customer)
    {
      address: {
        city: pay_customer.owner.city,
        country: pay_customer.owner.country
      },
      metadata: {
        pay_customer_id: pay_customer.id,
        user_id: id
      }
    }
  end
end
