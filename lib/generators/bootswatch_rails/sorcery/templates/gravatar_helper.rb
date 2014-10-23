module GravatarHelper
  def gravatar_url(<%= name %>, size)
    gravatar_id = Digest::MD5::hexdigest(<%= name %>.email).downcase
    "http://gravatar.com/avatar/#{gravatar_id}.png?s=#{size}"
  end
end
