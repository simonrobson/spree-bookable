class AddBookableFieldsToLineitems < ActiveRecord::Migration
  def self.up
    add_column :line_items, :start_date, :date
    add_column :line_items, :end_date, :date
  end

  def self.down
    remove_column :line_items, :end_date
    remove_column :line_items, :start_date
  end
end