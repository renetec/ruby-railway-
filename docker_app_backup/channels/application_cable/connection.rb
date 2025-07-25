module ApplicationCable
  class Connection < ActionCable::Connection::Base
    identified_by :current_user

    def connect
      self.current_user = find_verified_user
      logger.add_tags "ActionCable", "User #{current_user.id}"
    end

    private

    def find_verified_user
      if verified_user = User.find_by(id: cookies.encrypted[:user_id]) || 
                         env['warden']&.user
        verified_user.update_column(:last_seen_at, Time.current)
        verified_user
      else
        reject_unauthorized_connection
      end
    end
  end
end