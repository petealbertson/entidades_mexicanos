require 'roo'
require 'smarter_csv'
require 'uri'

class InegiDataImportService
  def self.import(file_path)
    new(file_path).import
  end

  def initialize(file_path)
    @file_path = file_path
    begin
      # Attempt to parse as URI and get path component
      uri = URI.parse(file_path)
      path = uri.path || file_path # Use original if no path component
    rescue URI::InvalidURIError
      # Fallback if it's not a valid URI (e.g., a local path)
      path = file_path
    end
    # Get extension from the path component (or original path if parsing failed)
    @extension = File.extname(path).downcase
  end

  def import
    ActiveRecord::Base.transaction do
      if @extension == '.xlsx' || @extension == '.xls'
        import_from_excel
      elsif @extension == '.csv'
        import_from_csv
      else
        raise "Unsupported file format: #{@extension}"
      end
    end
  end

  private

  def import_from_excel
    spreadsheet = Roo::Spreadsheet.open(@file_path)
    sheet = spreadsheet.sheet(0)
    
    # Skip header row
    current_estado = nil
    current_municipio = nil

    (2..sheet.last_row).each do |row_num|
      row = sheet.row(row_num)
      process_row(row)
    end
  end

  def import_from_csv
    options = { 
      chunk_size: 1000,
      remove_empty_values: false,
      strings_as_keys: true,
      downcase_header: true,
      force_utf8: true,
      file_encoding: 'utf-8',
      input_encoding: 'UTF-8',
      binary_mode: true,
      key_mapping: {
        'nom_ent' => :estado_nombre,
        'nom_abr' => :estado_abreviacion,
        'cve_ent' => :estado_clave,
        'nom_mun' => :municipio_nombre,
        'cve_mun' => :municipio_clave,
        'cve_loc' => :colonia_clave,
        'nom_loc' => :colonia_nombre,
        'lat_decimal' => :latitud,
        'lon_decimal' => :longitud,
        'altitud' => :altitud
      }
    }

    SmarterCSV.process(@file_path, options) do |chunk|
      chunk.each { |row| process_row(row) }
    end
  end

  def process_row(row)
    estado_clave = row[:estado_clave].to_s.rjust(2, '0')
    estado_nombre = row[:estado_nombre]
    estado_abreviacion = row[:estado_abreviacion]
    municipio_clave = row[:municipio_clave].to_s.rjust(3, '0')
    municipio_nombre = row[:municipio_nombre]
    colonia_clave = row[:colonia_clave]
    colonia_nombre = row[:colonia_nombre]
    latitud = row[:latitud]
    longitud = row[:longitud]
    altitud = row[:altitud]

    # Find or create estado
    estado = Estado.find_or_create_by!(clave: estado_clave) do |e|
      e.nombre = estado_nombre
      e.abbreviation = estado_abreviacion || generate_abbreviation(estado_nombre)
    end

    # Find or create municipio
    municipio = Municipio.find_or_create_by!(
      clave: municipio_clave,
      estado: estado
    ) do |m|
      m.nombre = municipio_nombre
    end

    # Create colonia
    Colonia.create!(
      clave: colonia_clave,
      nombre: colonia_nombre,
      municipio: municipio,
      latitud: latitud,
      longitud: longitud,
      altitud_msm: altitud
    )
  end

  def generate_abbreviation(nombre)
    case nombre
    when "Ciudad de México"
      "CDMX"
    else
      # Generate a simple abbreviation for other states
      nombre.split.map { |word| word[0] }.join.upcase
    end
  end
end
