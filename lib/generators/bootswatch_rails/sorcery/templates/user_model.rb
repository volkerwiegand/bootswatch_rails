class <%= class_name %> < ActiveRecord::Base
<%- if options.friendly? -%>
  include FriendlyId
  friendly_id :email, use: [:slugged]

<%- end -%>
  authenticates_with_sorcery!
  validates :email, presence: true, uniqueness: { case_sensitive: false }
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, unless: Proc.new { |a| a.password.blank? }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create
<%- if options.authority? -%>
  include Authority::UserAbilities
<%- end -%>

  default_scope { order(:name) }
  scope :active,  -> { where(active: true) }
  scope :sysadms, -> { where(sysadm: true) }
  
<%- if options.picture? -%>
  mount_uploader :picture, PictureUploader

<%- end -%>
  enum theme: BootswatchRails::THEMES
end
