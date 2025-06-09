class Import::InventoryMapping < Import::Mapping
  class << self
    def mappables_by_key(import)
      unique_values = import.rows.map(&:asset_customer_id).uniq
      unique_values.index_with { |value| nil } # pas d'auto-mapping
    end
  end

  def selectable_values
    import.family.accounts
      .where(accountable_type: "Inventory")
      .includes(:accountable)
      .map { |acc| [ acc.name, acc.accountable.id ] }
  end

  def requires_selection?
    true
  end

  def create_when_empty?
    false
  end

  def values_count
    import.rows.where(asset_customer_id: key).count
  end

  def mappable_class
    nil  
  end

  def mappable
    return nil unless value.present?
    Inventory.find_by(id: value)
  end

  def mappable_id
    mappable&.id || value
  end
end
