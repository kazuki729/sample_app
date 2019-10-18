require 'test_helper'

class RelationshipsControllerTest < ActionDispatch::IntegrationTest
  #未ログインでPOSTアクションにアクセスした場合、ログインを要求
  #アクションの前後で、Relationカウントが変わっていない事をチェック
  test "create should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      post relationships_path
    end
    assert_redirected_to login_url
  end
  #未ログインでDELETEアクションにアクセスした場合、ログインを要求
  #アクションの前後で、Relationカウントが変わっていない事をチェック
  test "destroy should require logged-in user" do
    assert_no_difference 'Relationship.count' do
      delete relationship_path(relationships(:one))
    end
    assert_redirected_to login_url
  end
end
