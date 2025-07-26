class UpdateEventDefaults < ActiveRecord::Migration[7.2]
  def change
    # Change location and capacity to be nullable
    change_column_null :events, :location, true
    change_column_null :events, :capacity, true
    
    # Change default status from 0 (draft) to 1 (published)
    change_column_default :events, :status, from: 0, to: 1
  end
end