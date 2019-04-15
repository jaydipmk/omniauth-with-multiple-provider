# frozen_string_literal: true

class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

  def self.provides_callback_for(provider)
    class_eval %Q{
      def #{provider}
        @user = User.from_omniauth(request.env['omniauth.auth'])
        if @user.persisted?
          flash[:notice] = I18n.t 'devise.omniauth_callbacks.success', kind: '#{provider}'
          sign_in_and_redirect @user, event: :authentication
        else
          session['devise.#{provider}_data'] = request.env['omniauth.auth'].except(:extra) # Removing extra as it can overflow some session stores
          redirect_to new_user_registration_url, alert: @user.errors.full_messages.join("\n")
        end
      end
    }
  end

  %i[ google_oauth2 twitter facebook linkedin ].each do |provider|
    provides_callback_for provider
  end

  # GET|POST /users/auth/oauth-provider/callback
  # def failure
  #   # super
  #   redirect_to root_path
  # end

  protected

  # The path used when OmniAuth fails
  def after_omniauth_failure_path_for(scope)
    super(scope)
  end
end
