class CreateMessages < ActiveRecord::Migration[5.1]
  def change
    create_table :messages do |t|
      t.text :content
      t.integer :from_id
      t.integer :to_id
      t.integer :room_id #型変更しました。（次ファイル参照）

      t.timestamps
    end
    add_index :messages, [:room_id, :created_at]
  end
end
