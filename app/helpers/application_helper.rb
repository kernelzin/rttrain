module ApplicationHelper

  def link_image(f)
    if f.object.data
      f.object.data
    else
      "#{}"
    end
  end

end
