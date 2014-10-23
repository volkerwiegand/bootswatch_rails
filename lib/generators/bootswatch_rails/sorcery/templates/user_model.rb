class <%= class_name %> < ActiveRecord::Base
  authenticates_with_sorcery!
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, unless: Proc.new { |a| a.password.blank? }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create

  has_many :assignments
  has_many :roles, through: :assignments
  has_many :abilities, through: :roles

<%- if options.picture? -%>
  mount_uploader :picture, PictureUploader

<%- end -%>
  enum theme: BootswatchRails::THEMES
end
