module AccountsHelper
  def summary_card(title:, &block)
    content = capture(&block)
    render "accounts/summary_card", title: title, content: content
  end

  def translated_accountable_type(account)
    type = account.accountable_type&.underscore
    return "" unless type.present?

    I18n.t("accountable_types.#{type}", default: type.titleize)
  end

  def translated_account_group_name(account_group)
    type = account_group.key.underscore
    I18n.t("accountable_types.#{type}", default: type.titleize)
  end

  def translated_account_group_label(account_group)
    key = account_group.key.to_s.underscore
    I18n.t("accountable_types.#{key}", default: key.titleize)
  end

  def translated_depository_subtypes
    Depository::SUBTYPES.map do |label, value|
      [I18n.t("depositories.subtypes.#{value}", default: label), value]
    end
  end
end
