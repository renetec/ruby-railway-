require_relative '../../services/database_backup_service'

class Admin::DatabaseController < AdminController
  def index
    @backup_files = list_backup_files
    @database_info = get_database_info
  end

  def backup
    begin
      backup_service = DatabaseBackupService.new
      backup_file = backup_service.create_backup
      
      if backup_file
        flash[:notice] = "Database backup created successfully: #{File.basename(backup_file)}"
      else
        flash[:alert] = "Failed to create database backup"
      end
    rescue => e
      Rails.logger.error "Database backup failed: #{e.message}"
      flash[:alert] = "Backup failed: #{e.message}"
    end

    redirect_to admin_database_index_path
  end

  def restore
    uploaded_file = params[:backup_file]
    
    if uploaded_file.blank?
      flash[:alert] = "Please select a backup file to restore"
      redirect_to admin_database_index_path and return
    end

    # Validate file extension
    unless uploaded_file.original_filename.end_with?('.sql', '.dump')
      flash[:alert] = "Invalid file type. Please upload a .sql or .dump file"
      redirect_to admin_database_index_path and return
    end

    begin
      backup_service = DatabaseBackupService.new
      result = backup_service.restore_backup(uploaded_file)
      
      if result
        flash[:notice] = "Database restored successfully from #{uploaded_file.original_filename}"
      else
        flash[:alert] = "Failed to restore database"
      end
    rescue => e
      Rails.logger.error "Database restore failed: #{e.message}"
      flash[:alert] = "Restore failed: #{e.message}"
    end

    redirect_to admin_database_index_path
  end

  def download_backup
    filename = params[:filename]
    backup_path = Rails.root.join('tmp', 'backups', filename)
    
    if File.exist?(backup_path)
      send_file backup_path, 
                filename: filename,
                type: 'application/sql',
                disposition: 'attachment'
    else
      flash[:alert] = "Backup file not found"
      redirect_to admin_database_index_path
    end
  end

  private

  def list_backup_files
    backup_dir = Rails.root.join('tmp', 'backups')
    Dir.mkdir(backup_dir) unless Dir.exist?(backup_dir)
    
    Dir.glob(File.join(backup_dir, '*.{sql,dump}')).map do |file|
      {
        name: File.basename(file),
        size: File.size(file),
        created_at: File.mtime(file)
      }
    end.sort_by { |f| f[:created_at] }.reverse
  end

  def get_database_info
    config = Rails.configuration.database_configuration[Rails.env]
    {
      database: config['database'],
      host: config['host'] || 'localhost',
      adapter: config['adapter']
    }
  rescue => e
    Rails.logger.error "Failed to get database info: #{e.message}"
    { error: e.message }
  end
end