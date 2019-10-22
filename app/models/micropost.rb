class Micropost < ApplicationRecord
  before_validation :set_in_reply_to #返信先の取得
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #DBのレコードを降順に並び変える
  mount_uploader :picture, PictureUploader  #MicropostモデルにUploaderを追加
  validates :user_id, presence: true #user_idの存在性バリデーション付加
  validates :content, presence: true, length: { maximum: 140 }
  validates :in_reply_to, presence: false
  validate  :picture_size #独自のメソッド（画像サイズ制限）
  validate  :reply_to_user #返信先のチェック

  def Micropost.including_replies(id)
      where(in_reply_to: [id, 0]).or(Micropost.where(user_id: id))
  end

  #マイクロポスト本文の内容チェック
  #@が含まれる場合、それ以降の数字（ID）を取得
  def set_in_reply_to
    if @index = content.index("@")
      #返信投稿の時
      reply_id = []
      while is_i?(content[@index+1])
        @index += 1
        reply_id << content[@index] #reply_idは配列
      end
      self.in_reply_to = reply_id.join.to_i #配列要素を繋げて、integerにする（例）[1,0,0]➡100
    else
      #普通の投稿の時
      self.in_reply_to = 0
    end
  end

  #数値チェック
  def is_i?(s)
    Integer(s) != nil rescue false
  end

  #返信先が正しいかチェック
  # 1. 返信先が指定されていない場合、チェックしない
  # 2. 指定したIDのユーザーが見つからない場合、エラーとする
  # 3. 自分自身に返信を行なった場合、エラーとする
  # 4. 指定したIDのユーザー名が間違っていた場合、エラーとする
  def reply_to_user
    return if self.in_reply_to == 0 # 1
    unless user = User.find_by(id: self.in_reply_to) # 2
      errors.add(:base, "User ID you specified doesn't exist.")
    else
      if user_id == self.in_reply_to # 3
        errors.add(:base, "You can't reply to yourself.")
      else
        unless reply_to_user_name_correct?(user) # 4
          errors.add(:base, "User ID doesn't match its name.")
        end
      end
    end
  end

  #指定されたIDのユーザー名が正しい事をチェック
  #（例）@10-Michael ➡IDが10のユーザーはMichaelかどうか？
  def reply_to_user_name_correct?(user)
    content[@index+2, user.name.length] == user.name #@と-の分だけ+2してる
  end

  private

    #アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
