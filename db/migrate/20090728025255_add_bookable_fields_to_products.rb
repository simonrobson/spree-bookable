class AddBookableFieldsToProducts < ActiveRecord::Migration
  def self.up
    add_column :products, :bookable, :boolean
    add_column :products, :ask_start_date, :boolean
    add_column :products, :ask_end_date, :boolean
  end

  def self.down
    remove_column :products, :ask_end_date
    remove_column :products, :ask_start_date
    remove_column :products, :bookable
  end
end