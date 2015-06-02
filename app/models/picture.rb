class Picture

  include Mongoid::Document

  field :name
  field :coords, type: Hash, default: { :x =>"", :x2 => "", :y => "", :y2 => "", :w => "", :h => ""}
  field :threshold, type: Integer

  mount_uploader :data, ImageUploader

  has_one :box

  belongs_to :font

  delegate :path, to: :font

  before_save :namez

  after_create :crop

  after_update :thresholder

  def namez
    write_attribute(:name, my_name)
    # This is equivalent:
    # self[:name] = new_name.upcase
  end

  def to_tmp
    unless File.exist?("#{fullpath}")
      download_pic
    end
  end

  def crop
    download_pic
    `convert #{fullpath} -crop #{coords[:w]}x#{coords[:h]}+#{coords[:x]}+#{coords[:y]} #{fullpath}`
    update_attribute(:data , File.open("#{fullpath}"))
    data.recreate_versions!
  end

  def fullpath
    "#{path}#{filename}"
  end

  def filename
    "#{my_name}#{File.extname(data.file.file)}"
  end

  def my_name
    "#{font.train.name}.#{font.name}.exp#{font.pictures.index(self)}"
  end

  def download_pic
    uri = data.file.is_a?(CarrierWave::SanitizedFile) ? data.file.path : data.url
    download_to_tmp(path, filename, uri)
  end

  def download_to_tmp(path, file, url)
    Dir.mkdir(path) unless Dir.exist?(path)
    File.open("#{path}/#{file}", 'wb') do |f|
      open(url, 'rb') { |u| f.write(u.read) }
    end
  end

  def thresholder
    to_tmp
    if threshold
      if box
        box.delete
      end
      `convert #{fullpath} -threshold #{threshold / 2.55}% #{fullpath}`
      to_box
    end
  end

  def to_box(language = "nota")
    `tesseract #{fullpath} #{path}/#{my_name} -l #{language} batch.nochop makebox`
    build_box()
    box.save!
  end

end
