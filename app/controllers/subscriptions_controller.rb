class SubscriptionsController < ApplicationController
  before_action :ensure_stripe_customer!

  def new
    unless Current.family.can_downgrade_to?(:base)
      redirect_to settings_billing_path,
                  alert: "Vous devez supprimer des comptes pour passer à l’abonnement Arion One. Limites : 1 stock, 1 dette personnalisée, 2 comptes bancaires.",
                  status: :see_other and return
    end

    cancel_previous_stripe_subscription

    session = Stripe::Checkout::Session.create(
      customer: Current.family.stripe_customer_id,
      line_items: [{ price: ENV["STRIPE_PLAN_BASE_ID"], quantity: 1 }],
      mode: "subscription",
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      automatic_tax: { enabled: true },
      customer_update: { address: 'auto' },
      success_url: success_subscription_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: settings_billing_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def upgrade
    unless Current.family.can_downgrade_to?(:premium)
      redirect_to settings_billing_path,
                  alert: "Vous devez supprimer des comptes pour passer à Arion One+. Limites : 3 stocks, 3 dettes personnalisées.",
                  status: :see_other and return
    end

    cancel_previous_stripe_subscription

    session = Stripe::Checkout::Session.create(
      customer: Current.family.stripe_customer_id,
      line_items: [{ price: ENV["STRIPE_PLAN_PREMIUM_ID"], quantity: 1 }],
      mode: "subscription",
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      automatic_tax: { enabled: true },
      customer_update: { address: 'auto' },
      success_url: success_subscription_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: settings_billing_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def enterprise
    cancel_previous_stripe_subscription

    session = Stripe::Checkout::Session.create(
      customer: Current.family.stripe_customer_id,
      line_items: [{ price: ENV["STRIPE_PLAN_COMPANY_ID"], quantity: 1 }],
      mode: "subscription",
      allow_promotion_codes: true,
      billing_address_collection: 'required',
      automatic_tax: { enabled: true },
      customer_update: { address: 'auto' },
      success_url: success_subscription_url + "?session_id={CHECKOUT_SESSION_ID}",
      cancel_url: settings_billing_url
    )

    redirect_to session.url, allow_other_host: true, status: :see_other
  end

  def show
    portal_session = Stripe::BillingPortal::Session.create(
      customer: Current.family.stripe_customer_id,
      return_url: settings_billing_url
    )

    redirect_to portal_session.url, allow_other_host: true, status: :see_other
  end

  def success
    session = Stripe::Checkout::Session.retrieve(params[:session_id])
    subscription = Stripe::Subscription.retrieve(session.subscription)
    plan_id = subscription.items.first.price.id

    family_attrs = {
      stripe_plan_id: nil,
      stripe_subscription_status: nil,
      stripe_premium_plan_id: nil,
      stripe_premium_subscription_status: nil,
      stripe_company_plan_id: nil,
      stripe_company_subscription_status: nil
    }

    case plan_id
    when ENV["STRIPE_PLAN_BASE_ID"]
      family_attrs.merge!(
        stripe_plan_id: plan_id,
        stripe_subscription_status: subscription.status
      )
    when ENV["STRIPE_PLAN_PREMIUM_ID"]
      family_attrs.merge!(
        stripe_premium_plan_id: plan_id,
        stripe_premium_subscription_status: subscription.status
      )
    when ENV["STRIPE_PLAN_COMPANY_ID"]
      family_attrs.merge!(
        stripe_company_plan_id: plan_id,
        stripe_company_subscription_status: subscription.status
      )
    end

    family_attrs[:subscribed_at] = Time.at(session.created)
    Current.family.update(family_attrs)

    redirect_to root_path, notice: "Abonnement mis à jour avec succès."
  rescue Stripe::InvalidRequestError
    redirect_to settings_billing_path, alert: "Une erreur est survenue avec l’abonnement."
  end

  private

  def ensure_stripe_customer!
    return if Current.family.stripe_customer_id.present?

    customer = Stripe::Customer.create(
      email: Current.family.primary_user.email,
      metadata: { family_id: Current.family.id }
    )

    Current.family.update(stripe_customer_id: customer.id)
  end

  def cancel_previous_stripe_subscription
    subscriptions = Stripe::Subscription.list(customer: Current.family.stripe_customer_id).data

    known_ids = [
      ENV["STRIPE_PLAN_BASE_ID"],
      ENV["STRIPE_PLAN_PREMIUM_ID"],
      ENV["STRIPE_PLAN_COMPANY_ID"]
    ]

    current_subscription = subscriptions.find do |s|
      s.items.first.price.id.in?(known_ids) && s.status == "active"
    end

    Stripe::Subscription.cancel(current_subscription.id) if current_subscription.present?
  end
end
