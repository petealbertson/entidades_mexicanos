require "test_helper"

class Api::V1::ColoniasControllerTest < ActionDispatch::IntegrationTest
  setup do
    @estado = estados(:one)
    @municipio = municipios(:one)
    @colonia = colonias(:one)
  end

  test "should get index" do
    get api_v1_colonias_url
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
  end

  test "should get nested index" do
    get api_v1_estado_municipio_colonias_url(@estado.clave, @municipio.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert response_body.all? { |c| c['municipio_id'] == @municipio.id }
  end

  test "should get direct show using primary key" do
    get api_v1_colonia_url(@colonia.id)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @colonia.nombre, response_body['nombre']
    assert_equal @colonia.id, response_body['id'] 
  end

  test "should get nested show" do
    get api_v1_estado_municipio_colonia_url(@estado.clave, @municipio.clave, @colonia.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @colonia.nombre, response_body['nombre']
    assert_equal @colonia.clave, response_body['clave']
  end

  test "should find colonias via index search" do
    get api_v1_colonias_url, params: { q: @colonia.nombre[0..3] }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
    assert response_body.any? { |c| c['nombre'].include?(@colonia.nombre[0..3]) }
  end

  test "should filter index by municipio (via nested route)" do
    get api_v1_estado_municipio_colonias_url(@estado.clave, @municipio.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.all? { |c| c['municipio']['id'] == @municipio.id } 
    assert response_body.all? { |c| c['municipio']['estado']['clave'] == @estado.clave } 
  end

  test "should filter index by estado and municipio (via nested route)" do
    get api_v1_estado_municipio_colonias_url(@estado.clave, @municipio.clave), params: { clave_estado: @estado.clave } 
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.all? { |c| c['municipio']['estado']['clave'] == @estado.clave }
    assert response_body.all? { |c| c['municipio']['clave'] == @municipio.clave }
  end
end
