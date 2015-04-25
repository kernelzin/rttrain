class Picture

  include Mongoid::Document

  field :name

  mount_uploader :data, ImageUploader

  embeds_one :box
  belongs_to :font

end
