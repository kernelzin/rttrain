class Box
  require 'open3'

  include Mongoid::Document

  belongs_to :picture

  embeds_many :chars, as: :charctertable
  # mount_uploader :data, ImageUploader
  after_save :from_picture

  delegate :my_name, :download_pic, :path, :filename, to: :picture

  def picf
    picture.font
  end

  def as_json(options = {})
    options.merge(id: id.to_s, chars: chars.as_json)
  end

  def from_picture(language = "nota")
    download_pic
    if picture.threshold
      `convert #{path}/#{filename} -threshold #{picture.threshold / 2.55}% #{path}/#{filename}`
    end
    `tesseract #{path}/#{filename} #{path}/#{my_name} -l #{language} batch.nochop makebox`
    from_file
  end

  def from_file
    file = "/tmp/#{picf.train.name}/#{my_name}.box"
    File.open(file).read.each_line do |l|
      c, x1, y1, x2,y2 = l.split(' ')
      chars.find_or_create_by(char: c, x1: x1, y1: y1, x2: x2, y2: y2)
    end
  end

  def to_file
    File.open "/tmp/#{picf.train.name}/#{my_name}.box", 'w' do |file|
      chars.each do |c|
        file.puts "#{c.char} #{c.x1} #{c.y1} #{c.x2} #{c.y2} 0"
      end
    end
  end

  def to_tr
    to_file
    file = "/tmp/#{picf.train.name}/#{my_name}"
    unless File.exist?("#{file}.jpg")
      download_pic
    end
    stdin, stdout, stderr, wait_thread = Open3.popen3("tesseract #{path}/#{filename} #{file} box.train.stderr")
    c = stderr.gets(nil)
    stderr.close()
    c = c.scan(/\((\d+),(\d*)\),\((\d+),(\d+)\)/)
    p c
    if c.is_a?(Array)
      c.each do |cc|
        p chars.where(:x1 => cc[0].to_i,
                      :y1 => cc[1].to_i,
                      :x2 => cc[2].to_i,
                      :y2 => cc[3].to_i).first.update_attributes(fail: true)
      end
    else
      c
      p c
    end
  end


end
