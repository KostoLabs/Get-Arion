module Breadcrumbable
  extend ActiveSupport::Concern

  included do
    before_action :set_breadcrumbs
  end

  private
    # The default, unless specific controller or action explicitly overrides
    def set_breadcrumbs
      @breadcrumbs = [
        [ I18n.t("breadcrumbs.home"), root_path ],
        [ I18n.t("breadcrumbs.controllers.#{controller_name}"), nil ]
      ]
    end
end
