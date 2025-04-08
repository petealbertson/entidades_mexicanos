require "test_helper"

class Api::V1::MunicipiosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @estado = estados(:one)
    @municipio = municipios(:one)
  end

  # Test the non-nested index route
  test "should get index" do
    get api_v1_municipios_url 
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    # Optionally check if it contains the expected municipio
    assert response_body.any? { |m| m['id'] == @municipio.id }
  end

  # Test the nested index route
  test "should get nested index" do
    get api_v1_estado_municipios_url(@estado.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
    # Assert all returned municipios belong to the correct estado
    assert response_body.all? { |m| m['estado']['clave'] == @estado.clave }
  end
  
  # Test the direct show route using primary key
  test "should get direct show using primary key" do
    get api_v1_municipio_url(@municipio.id) # Use primary key
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @municipio.nombre, response_body['nombre']
    assert_equal @municipio.id, response_body['id'] # Check primary key
    assert_not_nil response_body['estado']
  end

  # Test the nested show route
  test "should get nested show" do
    get api_v1_estado_municipio_url(@estado.clave, @municipio.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @municipio.nombre, response_body['nombre']
    assert_equal @municipio.clave, response_body['clave']
    assert_not_nil response_body['estado'] # Check estado is included
    assert_equal @estado.clave, response_body['estado']['clave']
  end

  # Test searching via the index route with 'q' param
  test "should find municipios via index search" do
    get api_v1_municipios_url, params: { q: @municipio.nombre[0..3] }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
    assert response_body.any? { |m| m['nombre'].include?(@municipio.nombre[0..3]) }
  end

  # Test filtering the nested index route with 'q' param
  test "should filter nested index by search query" do
    # Create another municipio in the same estado with a name that won't match
    unrelated_municipio = Municipio.create!(nombre: "ZZZ Unrelated", clave: '999', estado: @estado)
    search_term = @municipio.nombre[0..3] # e.g., "Muni" if @municipio.nombre is "Municipio One"
    
    get api_v1_estado_municipios_url(@estado.clave), params: { q: search_term }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
    # Should include the original municipio
    assert response_body.any? { |m| m['id'] == @municipio.id }
    # Should NOT include the unrelated municipio
    assert response_body.none? { |m| m['id'] == unrelated_municipio.id }, "Unrelated municipio should not be included in search results"
    # All results should belong to the correct estado
    assert response_body.all? { |m| m['estado']['clave'] == @estado.clave }
  end
end
