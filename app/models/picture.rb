class Picture

  include Mongoid::Document

  field :name

  field :threshold, type: Integer

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

  def path
    path = "/tmp/#{font.train.name}"
  end

  def filename
    filename = "#{my_name}#{File.extname(data.file.file)}"
  end

  def my_name
    "#{font.train.name}.#{font.name}.exp#{font.pictures.index(self)}"
  end

  def download_pic
    uri = data.file.is_a?(CarrierWave::SanitizedFile) ? data.file.path : data.url
    to_tmp(path, filename, uri)
  end

  def to_tmp(path, file, url)
    Dir.mkdir(path) unless Dir.exist?(path)
    File.open("#{path}/#{file}", 'wb') do |f|
      open(url, 'rb') { |u| f.write(u.read) }
    end
  end

  def boxer
    unless box
      build_box()
      box.save!
    else
      box.save!
    end
  end

end
