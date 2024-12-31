# Mexico Geographic Data API

This API provides access to Mexican geographic data, including estados (states), municipios (municipalities), and colonias (neighborhoods).

## Important Note

This API deliberately excludes population data. Population statistics become outdated very quickly after publication, and maintaining current population data would require constant updates. For the most up-to-date population information, please refer to INEGI's official population statistics.

## API Endpoints

### Estados (States)

#### List all Estados
```
GET /api/v1/estados
```
Returns a list of all Mexican states.

#### Get a specific Estado
```
GET /api/v1/estados/:clave
```
Returns details for a specific state by its clave (ID).

### Municipios (Municipalities)

#### List all Municipios
```
GET /api/v1/municipios?clave_estado=XX
```
Returns a list of all municipalities across Mexico. The `clave_estado` parameter is required.

#### List Municipios in an Estado
```
GET /api/v1/estados/:estado_clave/municipios
```
Returns all municipalities within a specific state.

#### Get a specific Municipio
```
GET /api/v1/municipios/:clave?clave_estado=XX
```
Returns details for a specific municipality. The `clave_estado` parameter is required.

#### Search Municipios
```
GET /api/v1/municipios/search
```
Search for municipalities. Supports the following query parameters:
- `q`: Search term for municipality name (case-insensitive)
- `clave_estado`: Filter by state clave

### Colonias (Neighborhoods)

#### List all Colonias
```
GET /api/v1/colonias
```
Returns a list of all neighborhoods across Mexico.

#### List Colonias in a Municipio
```
GET /api/v1/estados/:estado_clave/municipios/:municipio_clave/colonias
```
Returns all neighborhoods within a specific municipality.

#### Get a specific Colonia
```
GET /api/v1/colonias/:clave?clave_estado=XX
```
Returns details for a specific neighborhood. Requires `clave_estado` parameter.

#### Search Colonias
```
GET /api/v1/colonias/search
```
Search for neighborhoods. Supports the following query parameters:
- `q`: Search term for neighborhood name (case-insensitive)
- `clave_estado`: Filter by state clave
- `municipio_id`: Filter by municipality ID

## Response Format

All responses are in JSON format. Nested resources are included where relevant:
- Estados include their abbreviation and name
- Municipios include their estado
- Colonias include their municipio and estado

Example response for a colonia:
```json
{
  "id": 1,
  "clave": "0001",
  "nombre": "Centro",
  "latitud": "19.4326",
  "longitud": "-99.1332",
  "altitud_msm": "2250",
  "municipio": {
    "id": 1,
    "clave": "015",
    "nombre": "Cuauhtémoc",
    "estado": {
      "id": 1,
      "clave": "09",
      "nombre": "Ciudad de México",
      "abbreviation": "CDMX"
    }
  }
}
```

## Data Import

The API includes a rake task for importing INEGI data:

```bash
rake "inegi:import[path/to/file.csv]"
```

The CSV should include the following columns:
- NOM_ENT: Estado name
- NOM_ABR: Estado abbreviated name
- CVE_ENT: Estado clave
- NOM_MUN: Municipio name
- CVE_MUN: Municipio clave
- NOM_LOC: Colonia name
- CVE_LOC: Colonia clave
- LAT_DECIMAL: Latitude
- LON_DECIMAL: Longitude
- ALTITUD: Altitude in meters

Note: The CSV should be UTF-8 encoded to ensure proper handling of Spanish characters.

## Data Attribution

The geographic data provided by this API is sourced from the Instituto Nacional de Estadística y Geografía (INEGI), Mexico's National Institute of Statistics and Geography. Use of this data is subject to INEGI's terms and conditions, which can be found at:
[https://www.inegi.org.mx/contenidos/inegi/doc/terminos_info.pdf](https://www.inegi.org.mx/contenidos/inegi/doc/terminos_info.pdf)

When using this API, please ensure compliance with INEGI's terms of use and provide appropriate attribution to INEGI as the data source.
