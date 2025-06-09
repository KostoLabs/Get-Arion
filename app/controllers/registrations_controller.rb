class RegistrationsController < ApplicationController
  skip_authentication

  layout "auth"

  before_action :set_user, only: :create
  before_action :set_invitation
  before_action :claim_invite_code, only: :create, if: :invite_code_required?

  def new
    @user = User.new(email: @invitation&.email)
  end

  def create
    if @invitation
      @user.family = @invitation.family
      @user.role = @invitation.role
      @user.email = @invitation.email
    else
      family = Family.new
      @user.family = family
      @user.role = :admin
    end

    if @user.save
      @invitation&.update!(accepted_at: Time.current)
      @session = create_session_for(@user)
      redirect_to root_path, notice: t(".success")
    else
      render :new, status: :unprocessable_entity, alert: t(".failure")
    end
  end

  private

    def set_invitation
      token = params[:invitation]
      token ||= params[:user][:invitation] if params[:user].present?
      @invitation = Invitation.pending.find_by(token: token)
    end

    def set_user
      @user = User.new user_params.except(:invite_code, :invitation)

      @user.siren_temp = params[:user][:siren]
      @user.company_name_temp = params[:user][:company_name]
      @user.company_address_temp = params[:user][:company_address]
      @user.company_postal_code_temp = params[:user][:company_postal_code]
      @user.company_city_temp = params[:user][:company_city]
      @user.company_naf_temp = params[:user][:company_naf]
      @user.company_creation_date_temp = params[:user][:company_creation_date]
    end

    def user_params(specific_param = nil)
      params.require(:user).permit(
        :last_name, :first_name, :email, :password, :password_confirmation, :invite_code, :invitation,
        :siren, :company_name, :company_address, :company_postal_code, :company_city,
        :company_naf, :company_creation_date
      )
    end

    def claim_invite_code
      unless InviteCode.claim! params[:user][:invite_code]
        redirect_to new_registration_path, alert: t("registrations.create.invalid_invite_code")
      end
    end
end
