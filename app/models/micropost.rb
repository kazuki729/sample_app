class Micropost < ApplicationRecord
  belongs_to :user
  default_scope -> { order(created_at: :desc) } #DBのレコードを降順に並び変える
  mount_uploader :picture, PictureUploader  #MicropostモデルにUploaderを追加
  validates :user_id, presence: true #user_idの存在性バリデーション付加
  validates :content, presence: true, length: { maximum: 140 }
  validate  :picture_size #独自のメソッド（画像サイズ制限）

  private

    #アップロードされた画像のサイズをバリデーションする
    def picture_size
      if picture.size > 5.megabytes
        errors.add(:picture, "should be less than 5MB")
      end
    end
end
