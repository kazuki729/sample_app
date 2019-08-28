require 'test_helper'

class MicropostsControllerTest < ActionDispatch::IntegrationTest

  def setup
    @micropost = microposts(:orange)
  end

  #Micropostsコントローラの認可テスト
  test "should redirect create when not logged in" do
    assert_no_difference 'Micropost.count' do
      post microposts_path, params: { micropost: { content: "Lorem ipsum" } }
    end
    assert_redirected_to login_url
  end

  #Micropostsコントローラの認可テスト
  test "should redirect destroy when not logged in" do
    assert_no_difference 'Micropost.count' do
      delete micropost_path(@micropost)
    end
    assert_redirected_to login_url
  end

  #間違ったユーザーによるマイクロポスト削除に対してテスト
  test "should redirect destroy for wrong micropost" do
    log_in_as(users(:michael))  #michaelでログイン
    micropost = microposts(:ants) #IDが「ants」のmicropostを変数に代入
    #micropostの削除を実行し、削除が失敗する事を確認（削除試行前後のmicropost数で判断）
    assert_no_difference 'Micropost.count' do
      delete micropost_path(micropost)
    end
    assert_redirected_to root_url #root_urlにリダイレクトされている事を確認
  end
end
