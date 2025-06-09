class PagesController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[early_access]
  include Periodable

  def dashboard
    @balance_sheet = Current.family.balance_sheet
    @accounts = Current.family.accounts.active.with_attached_logo

    @coverage_ratio = CoverageRatioCalculator.new(
    family: Current.family,
    date: Date.current
  ).call

    @breadcrumbs = [ [ "Accueil", root_path ], [ "Tableau de bord", nil ] ]
  end

  def changelog
    @release_notes = Provider::Github.new.fetch_latest_release_notes || {
      avatar: view_context.asset_path("github-icon.svg"),
      username: "unknown",
      name: "Dernière mise à jour",
      body: "<p>Aucune note de version disponible pour le moment.</p>"
    }

    render layout: "settings"
  end

  def feedback
    render layout: "settings"
  end

  def early_access
    redirect_to root_path if self_hosted?

    @invite_codes_count = InviteCode.count
    @invite_code = InviteCode.order("RANDOM()").limit(1).first
    render layout: false
  end
end
