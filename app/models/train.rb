class Train

  include Mongoid::Document

  field :name

  has_many :fonts

  accepts_nested_attributes_for :fonts, allow_destroy: true

  after_create :create_font_properties

  after_update :update_font_properties


  def unichar_extrator
   `unicharset_extractor -D #{path} #{fonts.map(&:pictures).flatten.map(&:box).map(&:box_name).join(" ")}`
  end

  def create_dir
    Dir.mkdir(path) unless Dir.exist?(path)
  end

  def path
    "/tmp/#{name}/"
  end

  def font_properties
    "font_properties"
  end

  def update_font_properties
    if File.exist?("#{path}#{font_properties}")
      File.delete("#{path}#{font_properties}")
      create_font_properties
    else
      create_font_properties
    end

  end

  def create_font_properties
    create_dir
    File.open "#{path}#{font_properties}", 'w' do |file|
      fonts.each do |f|
        file.puts "#{f.properties} "
      end
    end
  end

end
