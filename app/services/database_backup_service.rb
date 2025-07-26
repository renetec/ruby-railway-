class DatabaseBackupService
  def initialize
    @backup_dir = Rails.root.join('tmp', 'backups')
    ensure_backup_directory
  end

  def create_backup
    timestamp = Time.current.strftime('%Y%m%d_%H%M%S')
    filename = "leclub_backup_#{timestamp}.sql"
    backup_path = @backup_dir.join(filename)

    success = if docker_environment?
      create_docker_backup(backup_path)
    else
      create_standard_backup(backup_path)
    end

    # Return the backup file path if successful, nil if failed
    success ? backup_path : nil
  end

  def restore_backup(uploaded_file)
    # Save uploaded file temporarily
    temp_path = @backup_dir.join("temp_restore_#{Time.current.to_i}.sql")
    
    File.open(temp_path, 'wb') do |file|
      file.write(uploaded_file.read)
    end

    success = if docker_environment?
      restore_docker_backup(temp_path)
    else
      restore_standard_backup(temp_path)
    end

    # Clean up temp file
    File.delete(temp_path) if File.exist?(temp_path)
    
    success
  end

  private

  def ensure_backup_directory
    Dir.mkdir(@backup_dir) unless Dir.exist?(@backup_dir)
  end

  def docker_environment?
    # Check if we're running in Docker
    File.exist?('/.dockerenv') || ENV['RAILS_ENV'] == 'development'
  end

  def database_config
    @database_config ||= Rails.configuration.database_configuration[Rails.env]
  end

  def create_docker_backup(backup_path)
    # For Docker development environment
    db_host = ENV['DATABASE_HOST'] || 'leclub_db_dev'
    db_name = ENV['DATABASE_NAME'] || database_config['database']
    db_user = ENV['DATABASE_USERNAME'] || database_config['username']
    db_password = ENV['DATABASE_PASSWORD'] || database_config['password']

    # Use pg_dump through Docker
    command = build_pg_dump_command(
      host: db_host,
      database: db_name,
      username: db_user,
      password: db_password,
      output_file: backup_path
    )

    execute_command(command)
  end

  def create_standard_backup(backup_path)
    # For Railway or standard PostgreSQL
    database_url = ENV['DATABASE_URL'] || build_database_url
    
    command = "pg_dump #{database_url} > #{backup_path}"
    execute_command(command)
  end

  def restore_docker_backup(backup_path)
    db_host = ENV['DATABASE_HOST'] || 'leclub_db_dev'
    db_name = ENV['DATABASE_NAME'] || database_config['database']
    db_user = ENV['DATABASE_USERNAME'] || database_config['username']
    db_password = ENV['DATABASE_PASSWORD'] || database_config['password']

    # Drop and recreate database, then restore
    commands = [
      build_dropdb_command(host: db_host, database: db_name, username: db_user, password: db_password),
      build_createdb_command(host: db_host, database: db_name, username: db_user, password: db_password),
      build_psql_restore_command(host: db_host, database: db_name, username: db_user, password: db_password, input_file: backup_path)
    ]

    commands.all? { |cmd| execute_command(cmd, ignore_errors: true) }
  end

  def restore_standard_backup(backup_path)
    database_url = ENV['DATABASE_URL'] || build_database_url
    
    # For Railway, we can't drop/create database, so we'll just restore over existing
    command = "psql #{database_url} < #{backup_path}"
    execute_command(command)
  end

  def build_pg_dump_command(host:, database:, username:, password:, output_file:)
    env_vars = "PGPASSWORD=#{password}"
    "#{env_vars} pg_dump -h #{host} -U #{username} -d #{database} --no-owner --no-privileges --clean --if-exists > #{output_file}"
  end

  def build_dropdb_command(host:, database:, username:, password:)
    env_vars = "PGPASSWORD=#{password}"
    "#{env_vars} dropdb -h #{host} -U #{username} #{database} --if-exists"
  end

  def build_createdb_command(host:, database:, username:, password:)
    env_vars = "PGPASSWORD=#{password}"
    "#{env_vars} createdb -h #{host} -U #{username} #{database}"
  end

  def build_psql_restore_command(host:, database:, username:, password:, input_file:)
    env_vars = "PGPASSWORD=#{password}"
    "#{env_vars} psql -h #{host} -U #{username} -d #{database} < #{input_file}"
  end

  def build_database_url
    config = database_config
    user = config['username']
    password = config['password']
    host = config['host'] || 'localhost'
    port = config['port'] || 5432
    database = config['database']
    
    "postgresql://#{user}:#{password}@#{host}:#{port}/#{database}"
  end

  def execute_command(command, ignore_errors: false)
    Rails.logger.info "Executing database command: #{command.gsub(/PGPASSWORD=\S+/, 'PGPASSWORD=***')}"
    
    result = system(command)
    
    if result || ignore_errors
      Rails.logger.info "Database command completed successfully"
      true
    else
      Rails.logger.error "Database command failed"
      false
    end
  end
end