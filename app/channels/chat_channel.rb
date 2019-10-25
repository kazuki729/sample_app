class ChatChannel < ApplicationCable::Channel
  #ChannelはPublishされたコンテンツ(Broadcast)をSubscriberにルーティングできる。
  def subscribed
    stream_from "chat_channel_#{params[:room_id]}"
  end

  def unsubscribed
  end

  def speak(data)
    from_user = User.find_by(id: data['from_id'].to_s) #送信者
    to_user = User.find_by(id: data['to_id'].to_s) #受信者
    from_user.send_message(to_user, data['room_id'], data['content']) #メッセージ送信
  end
end
