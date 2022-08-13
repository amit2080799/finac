# frozen_string_literal: true

# migration to create client configurations
class CreateClientConfigurations < ActiveRecord::Migration[7.0]
  def change
    create_table :client_configurations do |t|
      t.string :name, null: false
      t.string :code
      t.string :value

      t.timestamps
    end
  end
end
