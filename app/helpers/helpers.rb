module Helpers
    def self.current_user(session)
        session[:user_id]
    end

    def self.is_logged_in?(session)
        !!session[:user_id]
    end

    def self.displayable_version(str)
        if str.match(/_/)
            transformed_key = str.split(/_/).map(&:capitalize).join(' ')
        else
            transformed_key = str.capitalize
        end
    end

    def self.set_flash(session, message, from_get=false)
        session[:flash] << message
        session[:from_get] = true if from_get
    end

end