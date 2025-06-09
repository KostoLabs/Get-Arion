module ImportsHelper
  def mapping_label(mapping_class)
    {
      "Import::AccountTypeMapping" => "Account Type",
      "Import::AccountMapping" => "Account",
      "Import::CategoryMapping" => "Category",
      "Import::TagMapping" => "Tag",
      "Import::InventoryMapping" => "Inventory"
    }.fetch(mapping_class.name)
  end

  def import_col_label(key)
    {
      date: "Date",
      amount: "Montant",
      name: "Nom",
      currency: "Devise",
      category: "Catégorie",
      tags: "Tags",
      account: "Compte",
      notes: "Notes",
      qty: "Quantité",
      ticker: "Code valeur",
      exchange: "Place boursière",
      price: "Prix unitaire",
      entity_type: "Type d'entité"
    }[key.to_sym] || key.to_s.humanize
  end

  def dry_run_resource(key)
    map = {
      transactions: DryRunResource.new(label: "Transactions", icon: "credit-card", text_class: "text-cyan-500", bg_class: "bg-cyan-500/5"),
      accounts: DryRunResource.new(label: "Comptes", icon: "layers", text_class: "text-orange-500", bg_class: "bg-orange-500/5"),
      categories: DryRunResource.new(label: "Catégories", icon: "shapes", text_class: "text-blue-500", bg_class: "bg-blue-500/5"),
      tags: DryRunResource.new(label: "Tags", icon: "tags", text_class: "text-violet-500", bg_class: "bg-violet-500/5"),
      inventories:  DryRunResource.new(label: "Stocks", icon: "package", text_class: "text-green-600", bg_class: "bg-green-100"),
      articles: DryRunResource.new(label: "Articles", icon: "box", text_class: "text-purple-600", bg_class: "bg-purple-100") 
    }

    map[key]
  end

  def permitted_import_configuration_path(import)
    if permitted_import_types.include?(import.type.underscore)
      "import/configurations/#{import.type.underscore}"
    else
      raise "Type d'import inconnu : #{import.type}"
    end
  end

  def cell_class(row, field)
    base = "text-sm focus:ring-gray-900 focus:border-gray-900 w-full max-w-full disabled:text-subdued"

    row.valid? # populate errors

    border = row.errors.key?(field) ? "border-red-500" : "border-transparent"

    [ base, border ].join(" ")
  end

  private

  def permitted_import_types
    %w[transaction_import trade_import account_import mint_import]
  end

  DryRunResource = Struct.new(:label, :icon, :text_class, :bg_class, keyword_init: true)
end
