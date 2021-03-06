# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

# データベース上にサンプルユーザーを生成するRailsタスク
# create!はユーザーが無効の場合に例外を発生させてくれる
# Firstユーザーのみadmin属性をTrueに設定する
User.create!(name:  "Example User",
             email: "example@railstutorial.org",
             password:              "foobar",
             password_confirmation: "foobar",
             admin: true,
             activated: true,
             activated_at: Time.zone.now)

99.times do |n|
  name  = Faker::Name.name
  email = "example-#{n+1}@railstutorial.org"
  password = "password"
  User.create!(name:  name,
               email: email,
               password:              password,
               password_confirmation: password,
               activated: true,
               activated_at: Time.zone.now)
end

users = User.order(:created_at).take(6) #最初の６人だけ取り出す
50.times do
  content = Faker::Lorem.sentence(5)
  users.each { |user| user.microposts.create!(content: content) }
end

# リレーションシップ
users = User.all
user  = users.first
following = users[2..50]  #usersの3番目から51番目※配列だから0始まり
followers = users[3..40]  #usersの4番目から41番目※配列だから0始まり
following.each { |followed| user.follow(followed) } #最初のユーザーが3~51番目までのユーザーをフォローする
followers.each { |follower| follower.follow(user) } #4~41番目のユーザーが最初のユーザーをフォローする
