class ApplicationController < ActionController::Base
  include Onboardable, Localize, AutoSync, Authentication, Invitable, SelfHostable, StoreLocation, Impersonatable, Breadcrumbable
  include Pagy::Backend

  helper_method :require_upgrade?, :subscription_pending?

  before_action :detect_os, :set_locale

  private

  def set_locale
    I18n.locale = :fr
  end

  def require_upgrade?
    return false if self_hosted?
    return false unless Current.session
    return false if Current.family.subscribed?
    return false if subscription_pending? || request.path == settings_billing_path
    return false if Current.family.active_accounts_count <= 3

    true
  end

  def subscription_pending?
    subscribed_at = Current.session.subscribed_at
    subscribed_at.present? && subscribed_at <= Time.current && subscribed_at > 1.hour.ago
  end

  def require_account_creation_subscription!
    unless Current.family&.can_add_account?
      redirect_to settings_billing_path,
                  alert: Current.family.account_limit_message || "Vous devez être abonné pour ajouter un compte.",
                  status: :see_other
    end
  end

  def require_import_subscription!
    unless Current.family&.can_import?
      redirect_to settings_billing_path,
                  alert: "Vous devez être abonné pour effectuer des imports.",
                  status: :see_other
    end
  end


  def detect_os
    user_agent = request.user_agent
    @os = case user_agent
    when /Windows/i then "windows"
    when /Macintosh/i then "mac"
    when /Linux/i then "linux"
    when /Android/i then "android"
    when /iPhone|iPad/i then "ios"
    else ""
    end
  end
end
