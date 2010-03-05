class CreatePostalCodes < ActiveRecord::Migration
  def self.up
    create_table :postal_codes do |t|
      t.column :postal_code, :string
    end
    create_table :mps_postal_codes, :id => false do |t|
      t.column :mp_id, :integer
      t.column :postal_code_id, :integer
    end
  end

  def self.down
    drop_table :postal_codes
    drop_table :mps_postal_codes
  end
end
