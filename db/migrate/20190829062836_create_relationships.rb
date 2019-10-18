class CreateRelationships < ActiveRecord::Migration[5.1]
  def change
    create_table :relationships do |t|
      t.integer :follower_id
      t.integer :followed_id

      t.timestamps
    end
    #インデックスは検索が頻繁に行われるカラムに張る
    #多くのデータを格納するテーブルに効果的
    #[メリット・デメリット]データの読み込み・取得が速くなる一方、書き込みの速度が倍かかる
    add_index :relationships, :follower_id
    add_index :relationships, :followed_id
    #複合キーインデックス（あるユーザーが同じユーザーを２回以上フォローできない）
    add_index :relationships, [:follower_id, :followed_id], unique: true
  end
end
