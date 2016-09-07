module CreatedByHelper
  def text_created_by(model, action = "create", mode = "short")
    begin
      if action.include?("update")
        id = model.updated_by
        time = model.updated_at
      else
        id = model.created_by
        time = model.created_at
      end
      user = <%= user.camelize %>.<%= options.friendly? ? 'friendly.' : '' %>find(id)
      name = user.name
      email = user.email
    rescue
      return ""
    end
    case mode
      when "name"
        name
      when "email"
        email
      when "user"
        mail_to(email, name)
      when "long"
        "#{mail_to(email, name)} (#{l(time)})"
      when "link"
        "#{link_to(name, user)} (#{l(time.to_date)})"
      else          
        "#{mail_to(email, name)} (#{l(time.to_date)})"
    end
  end
end
