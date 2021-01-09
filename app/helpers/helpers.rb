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

    def self.set_flash(session)
        session[:flash] = @flash
    end

    def self.display_flash(session)
        if session[:flash]
            add_error(session.delete(:flash))
        end
    end

end