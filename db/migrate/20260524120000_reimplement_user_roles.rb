# frozen_string_literal: true

class ReimplementUserRoles < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :role, :string, null: false, default: 'user'

    say_with_time 'Migrating roles array to single role' do
      execute <<~SQL.squish
        UPDATE users
        SET role = CASE
          WHEN 'super_admin' = ANY(roles) THEN 'super_admin'
          WHEN 'admin' = ANY(roles) THEN 'admin'
          ELSE 'user'
        END
      SQL
    end

    remove_column :users, :roles
    add_index :users, :role
  end

  def down
    add_column :users, :roles, :string, array: true, default: []

    say_with_time 'Migrating single role back to roles array' do
      execute <<~SQL.squish
        UPDATE users SET roles = ARRAY[role]
      SQL
    end

    remove_index :users, :role
    remove_column :users, :role
  end
end
