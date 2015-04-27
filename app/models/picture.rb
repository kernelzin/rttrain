class Picture

  include Mongoid::Document

  mount_uploader :data, ImageUploader

  has_one :box

  belongs_to :font

  after_save :boxer

  def boxer
    box = Box.new
    box.picture_id = id.to_s
    box.save
  end

end
