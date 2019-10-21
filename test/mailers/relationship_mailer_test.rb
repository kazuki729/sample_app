require 'test_helper'

class RelationshipMailerTest < ActionMailer::TestCase
  #メールの内容チェック（フォロー版）
  test "follow_notification" do
    user = users(:notif)  #通知を受け取るユーザー（フォローされる側）
    follower = users(:archer) #フォローする側
    mail = RelationshipMailer.follow_notification(user, follower) #メールを作成する
    assert_equal "#{follower.name} started following you", mail.subject #メールの件名チェック
    assert_equal [user.email], mail.to #メール受信者アドレスチェック
    assert_equal ["noreply@example.com"], mail.from #メール送信者アドレスチェック
    assert_match user.name, mail.body.encoded #フォローされた人の名前がメール本文に含まれている事をチェック
    assert_match follower.name, mail.body.encoded #フォローした人の名前がメール本文に含まれている事をチェック
  end

  #メールの内容チェック（アンフォロー版）
  test "unfollow_notification" do
    user = users(:notif)
    follower = users(:archer)
    mail = RelationshipMailer.unfollow_notification(user, follower)
    assert_equal "#{follower.name} unfollowed you", mail.subject
    assert_equal [user.email], mail.to
    assert_equal ["noreply@example.com"], mail.from
    assert_match user.name, mail.body.encoded
    assert_match follower.name, mail.body.encoded
  end
end
