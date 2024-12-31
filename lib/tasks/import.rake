namespace :inegi do
  desc 'Import INEGI data from Excel/CSV file'
  task :import, [:file_path] => :environment do |t, args|
    unless args[:file_path]
      puts "Please provide a file path: rake inegi:import[path/to/file.xlsx]"
      exit
    end

    begin
      puts "Starting import from #{args[:file_path]}..."
      InegiDataImportService.import(args[:file_path])
      puts "Import completed successfully!"
    rescue StandardError => e
      puts "Error during import: #{e.message}"
      puts e.backtrace
      exit 1
    end
  end
end
