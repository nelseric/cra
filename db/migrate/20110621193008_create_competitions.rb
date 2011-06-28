class CreateCompetitions < ActiveRecord::Migration
  def self.up
    create_table :competitions do |t|
      t.integer :year
      t.string :event
      t.string :event_subtype
      t.integer :registered_teams
      t.timestamps
    end
  end

  def self.down
    drop_table :competitions
  end
end
