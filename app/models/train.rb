class Train

  include Mongoid::Document

  field :name

  has_many :fonts

  accepts_nested_attributes_for :fonts, allow_destroy: true

  after_create :create_font_properties

  after_update :update_font_properties

  def font_properties
    "/tmp/#{name}/font_properties"
  end

  def update_font_properties
    if File.exist?(font_properties)
      File.delete(font_properties)
      create_font_properties
  end

  def create_font_properties
    File.open "/tmp/#{name}/font_properties", 'w' do |file|
      fonts.each do |f|
        file.puts "#{f.properties} "
      end
    end
  end

end
