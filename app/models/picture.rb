class Picture

  include Mongoid::Document

  field :name

  mount_uploader :data, ImageUploader

  has_one :box

  belongs_to :font

  after_save :boxer

  before_save :namez

  def namez
    write_attribute(:name, my_name)
    # This is equivalent:
    # self[:name] = new_name.upcase
  end

  def my_name
    "#{font.train.name}.#{font.name}.exp#{font.pictures.index(self)}"
  end

  def boxer
    build_box()
    box.save!
  end

end
