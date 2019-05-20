class User < ApplicationRecord
  # email属性を小文字に変換してメールアドレスの一意性を保証する
  before_save { self.email = email.downcase }
  # 名前の制約
  validates :name, presence: true, length: { maximum: 50}
  # メアドの制約
  #VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  validates :email, presence: true, length: { maximum: 255},
                    format: { with: VALID_EMAIL_REGEX },
                    uniqueness: { case_sensitive: false }
  has_secure_password
  # パスワードの文字制限
  validates :password, presence: true, length: { minimum: 6 }
end
