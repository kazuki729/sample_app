class ChangeDatatypeRoomId < ActiveRecord::Migration[5.1]
  def change
    change_column :messages, :room_id, :string
  end
end
