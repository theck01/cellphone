class ExperimentLog < ActiveRecord::Base
  validates :experiment_name, presence: true
  validates :drug_name, presence: true
  validates :drug_ul_dose, presence: true
  validates :drug_ul_dose, presence: true

  # overriden create method adds application time to params hash
  def ExperimentLog.create(params)
    params[:application_time] = Time.now
    super(params)
  end
end
