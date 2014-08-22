module CreatedByHelper
  def text_created_by(model, action = "create", mode = "short")
    begin
      id = model.send("#{action}d_by")
      time = model.send("#{action}d_at")
      user = <%= user.camelize %>.find(id)
      name = user.name
      email = user.email
    rescue
      return ""
    end
    case mode in
      when "name"
        name
      when "email"
        email
      when "user"
        mail_to(email, name)
      when "long"
        "#{mail_to(email, name)} (#{l(time)})"
      else          
        "#{mail_to(email, name)} (#{l(time.to_date)})"
    end
  end
end
