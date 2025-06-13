class Account::ValuationsController < ApplicationController
  include EntryableResource

  def update
    set_entry  # méthode définie dans EntryableResource pour charger @entry

    if @entry.update(update_entry_params)
      @entry.sync_account_later

      respond_to do |format|
        format.html { redirect_back_or_to account_path(@entry.account), notice: t("account.entries.update.success") }
        format.turbo_stream do
          render turbo_stream: [
            turbo_stream.replace(
              "header_account_entry_#{@entry.id}",
              partial: "#{entryable_type.name.underscore.pluralize}/header",
              locals: { entry: @entry }
            ),
            turbo_stream.replace("account_entry_#{@entry.id}", partial: "account/entries/entry", locals: { entry: @entry })
          ]
        end
      end
    else
      calculator = Account::BalanceTrendCalculator.for([@entry])
      @balance_trend = calculator&.trend_for(@entry)

      render :show, status: :unprocessable_entity
    end
  end
end
