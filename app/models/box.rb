class Box
  include Mongoid::Document

  belongs_to :picture

  embeds_many :chars, as: :charctertable
  # mount_uploader :data, ImageUploader
  after_create :picturize

  delegate :my_name, to: :picture

  def picf
    picture.font
  end

  def picturize
    from_picture(picture)
  end

  def download_tmp(path, file, url)
    Dir.mkdir(path) unless Dir.exist?(path)
    File.open("#{path}/#{file}", 'wb') do |f|
      open(url, 'rb') { |u| f.write(u.read) }
    end
  end

  def as_json(options = {})
    options.merge(name: name, pic: picture.data,  chars: chars.as_json)
  end

  def from_picture(picture, language = "nota")
    path = "/tmp/#{picf.train.name}"
    filename = "#{my_name}#{File.extname(picture.data.file.file)}"
    uri = picture.data.file.is_a?(CarrierWave::SanitizedFile) ? picture.data.file.path : picture.data.url
    download_tmp(path, filename, uri)
    `tesseract #{path}/#{filename} #{path}/#{my_name} -l #{language} batch.nochop makebox`
    from_file
  end

  def from_file
    file = "/tmp/#{picf.train.name}/#{my_name}.box"
    File.open(file).read.each_line do |l|
      c, x1, y1, x2,y2 = l.split(' ')
      chars.create(char: c, x1: x1, y1: y1, x2: x2, y2: y2)
    end
  end

end
