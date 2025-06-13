class SubscriptionsController < ApplicationController
  before_action :ensure_stripe_customer!

  def new
    if Current.family.subscribed_to_premium? && Current.family.active_accounts_count > 2
      redirect_to settings_billing_path,
                  alert: "Vous devez supprimer des comptes pour repasser à l’abonnement Arion+. L’abonnement Arion+ ne permet qu’un seul compte actif."
      return
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

    if plan_id == ENV["STRIPE_PLAN_BASE_ID"]
      Current.family.update(
        stripe_plan_id: plan_id,
        stripe_subscription_status: subscription.status,
        subscribed_at: Time.at(session.created),
        stripe_premium_plan_id: nil,
        stripe_premium_subscription_status: nil
      )
    elsif plan_id == ENV["STRIPE_PLAN_PREMIUM_ID"]
      Current.family.update(
        stripe_premium_plan_id: plan_id,
        stripe_premium_subscription_status: subscription.status,
        stripe_plan_id: nil,
        stripe_subscription_status: nil
      )
    end

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

  def redirect_to_root_if_self_hosted
    redirect_to root_path, alert: I18n.t("subscriptions.self_hosted_alert") if self_hosted?
  end

  def cancel_previous_stripe_subscription
    subscriptions = Stripe::Subscription.list(customer: Current.family.stripe_customer_id).data

    base_id    = ENV["STRIPE_PLAN_BASE_ID"]
    premium_id = ENV["STRIPE_PLAN_PREMIUM_ID"]

    current_subscription = subscriptions.find do |s|
      s.items.first.price.id.in?([ base_id, premium_id ]) && s.status == "active"
    end

    Stripe::Subscription.cancel(current_subscription.id) if current_subscription.present?
  end
end
