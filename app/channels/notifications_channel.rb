class NotificationsChannel < ApplicationCable::Channel
  def self.broadcast_changed(user)
    NotificationsChannel.broadcast_to(user, { type: "notifications.changed" })
  end

  def subscribed
    stream_for current_user
  end

  def unsubscribed; end
end
