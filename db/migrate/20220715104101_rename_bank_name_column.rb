class RenameBankNameColumn < ActiveRecord::Migration[7.0]
  def change
    rename_column :bank_details, :bank_name, :name
  end
end
