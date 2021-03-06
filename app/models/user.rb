class User < ApplicationRecord
  has_many :microposts, dependent: :destroy  #１ユーザーが複数のmicropostを所有する.また、ユーザーが削除されたとき、紐づいている投稿も削除される.
  has_many :active_relationships, class_name:  "Relationship",
                                  foreign_key: "follower_id",
                                  dependent:   :destroy
  has_many :passive_relationships, class_name:  "Relationship",
                                   foreign_key: "followed_id",
                                   dependent:   :destroy
  #Relationshipモデル関係
  has_many :following, through: :active_relationships, source: :followed #followingの関連付け
  has_many :followers, through: :passive_relationships, source: :follower
  #Messageモデル関連
  has_many :from_messages, class_name: "Message", foreign_key: "from_id", dependent: :destroy
  has_many :to_messages, class_name: "Message", foreign_key: "to_id", dependent: :destroy
  has_many :sent_messages, through: :from_messages, source: :from
  has_many :received_messages, through: :to_messages, source: :to

  attr_accessor :remember_token, :activation_token, :reset_token
  before_save   :downcase_email
  before_create :create_activation_digest
  attr_accessor :remember_token
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
  validates :password, presence: true, length: { minimum: 6 }, allow_nil: true

  # 渡された文字列のハッシュ値を返す
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end

  # ランダムなトークンを返す
  def User.new_token
    SecureRandom.urlsafe_base64
  end

  # 永続セッションのためにユーザーをデータベースに記憶する
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end

  # 渡されたトークンがダイジェストと一致したらtrueを返す
  def authenticated?(attribute, token)
    digest = send("#{attribute}_digest")
    return false if digest.nil?
    BCrypt::Password.new(digest).is_password?(token)
  end
  #def authenticated?(remember_token)
  #  return false if remember_digest.nil?
  #  BCrypt::Password.new(remember_digest).is_password?(remember_token)
  #end

  def forget
    update_attribute(:remember_digest, nil)
  end

  #アカウントを有効にする
  def activate
    #update_attribute(:activated, true)
    #update_attribute(:activated_at, Time.zone.now)
    update_columns(activated: true, activated_at: Time.zone.now)
  end

  #有効化用のメールを送信する
  def send_activation_email
    UserMailer.account_activation(self).deliver_now
  end

  #パスワード再設定の属性を設定する
  def create_reset_digest
    self.reset_token = User.new_token
    #update_attributeをupdate_columnsで１行にまとめている
    update_columns(reset_digest:  User.digest(reset_token), reset_sent_at: Time.zone.now)
    #update_attribute(:reset_digest, User.digest(reset_token))
    #update_attribute(:reset_sent_at, Time.zone.now)
  end

  #パスワード再設定のメールを送信する
  def send_password_reset_email
    UserMailer.password_reset(self).deliver_now
  end

  #パスワード再設定の期限が切れている場合はTRUEを返す
  def password_reset_expired?
    reset_sent_at < 2.hours.ago
  end

  #ユーザーのステータスフィードを返す
  def feed
    # Micropost.where("user_id IN (?) OR user_id = ?", following_ids, id)
    # Micropost.where("user_id IN (:following_ids) OR user_id = :user_id", following_ids: following_ids, user_id: id)
    #SQLのサブセレクト（集合のロジックをDB内に保存するため、効率がいい）
    following_ids = "SELECT followed_id FROM relationships
                     WHERE follower_id = :user_id"
    Micropost.including_replies(id)
                       .where("user_id IN (#{following_ids})
                              OR user_id = :user_id", user_id: id)
  end

  #ユーザーをフォローする
  def follow(other_user)
    #「<<」は配列の最後にデータを追加
    following << other_user
    #通知メール送信
    if other_user.follow_notification
      #通知設定がONの場合
      Relationship.send_follow_email(other_user, self)
    end
  end

  #ユーザーをフォロー解除する
  def unfollow(other_user)
    active_relationships.find_by(followed_id: other_user.id).destroy
    #通知メール送信
    if other_user.follow_notification
      #通知設定がONの場合
      Relationship.send_unfollow_email(other_user, self)
    end
  end

  #現在のユーザーがフォローしてたらTRUEを返す
  def following?(other_user)
    following.include?(other_user)
  end

  # メッセージを送信する
  def send_message(other_user, room_id, content)
    #create!はレコード追加に失敗した場合、例外を発生させる
    from_messages.create!(to_id: other_user.id, room_id: room_id, content: content)
  end

  private

    # メールアドレスをすべて小文字にする
    def downcase_email
      # self.email = email.downcaseの短縮系
      # emailを小文字化してUserオブジェクトのemail属性に代入
      email.downcase!
    end

    # 有効かトークンとダイジェストを作成および代入する
    def create_activation_digest
      self.activation_token = User.new_token
      self.activation_digest = User.digest(activation_token)
    end
end
