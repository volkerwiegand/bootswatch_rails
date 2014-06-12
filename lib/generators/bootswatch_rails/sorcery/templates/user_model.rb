class <%= class_name %> < ActiveRecord::Base
  authenticates_with_sorcery!
  validates :email, presence: true, uniqueness: true
  validates :password, presence: true, on: :create
  validates :password, length: { minimum: 6 }, unless: Proc.new { |a| a.password.blank? }
  validates :password, confirmation: true
  validates :password_confirmation, presence: true, on: :create

  enum status: <%= BootswatchRails::USER_STATUS %>
  validates :status, presence: true

  enum theme: BootswatchRails::THEMES
end
