class Message < ApplicationRecord
  # Asociations
  belongs_to :from, class_name: "User"
  belongs_to :to, class_name: "User"

  # Scopes
  default_scope -> {order(created_at: :asc)} #messageモデルに関するクエリは作成日時昇順で発行される（古い日付から順）

  # Validations
  validates :from_id, presence: true
  validates :to_id, presence: true
  validates :room_id, presence: true
  validates :content, presence: true, length: {maximum: 50} #本文は50文字まで

  # Callbacks
  after_create_commit { MessageBroadcastJob.perform_later self }

  #指定されたルームIDの新しいメッセージを最大500件取得
  def Message.recent_in_room(room_id)
    where(room_id: room_id).last(500)
  end

end
