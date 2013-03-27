class CreateExperimentLogs < ActiveRecord::Migration
  def up
    create_table :experiment_logs do |t|
      t.text :experiment_name
      t.text :drug_name
      t.float :drug_ul_dose
      t.datetime :application_time
    end
  end

  def down
    drop_table :experiment_logs
  end
end
