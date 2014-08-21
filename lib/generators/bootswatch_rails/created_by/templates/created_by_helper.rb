module CreatedByHelper
  def text_created_by(model, mode = "create", full = true)
    begin
      id = model.send("#{mode}d_by")
      day = model.send("#{mode}d_at").to_date
      user = User.find(id)
      name = user.name
    rescue
      return "???"
    end
    return name unless full
    "#{mail_to(user.email, name)} (#{l(day)})"
  end
end
