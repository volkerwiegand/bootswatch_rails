module ApplicationHelper
  def app_name
    "Demo Application"
  end

  def page_title(title_text)
    content_for(:title) { "#{title_text} - #{app_name}" }
  end

  def brand_logo
    image_tag("Rails_logo_80.jpg")
  end

  def copyright_year
    Time.now.year
  end

  def copyright_text
    "Copyright Holder"
  end

  def copyright_link
    "http://www.example.com/"
  end
end
