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

  test "should get show with clave_estado" do
    get api_v1_colonia_url(@colonia.clave, clave_estado: @estado.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @colonia.nombre, response_body['nombre']
    assert_equal @colonia.clave, response_body['clave']
    assert_not_nil response_body['municipio']
    assert_not_nil response_body['municipio']['estado']
  end

  test "should get nested show" do
    get api_v1_estado_municipio_colonia_url(@estado.clave, @municipio.clave, @colonia.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @colonia.nombre, response_body['nombre']
    assert_equal @colonia.clave, response_body['clave']
  end

  test "should require clave_estado for direct show" do
    get api_v1_colonia_url(@colonia.clave)
    assert_response :unprocessable_entity
    
    response_body = JSON.parse(response.body)
    assert_includes response_body['error'], 'clave_estado'
  end

  test "should search colonias" do
    get search_api_v1_colonias_url, params: { q: @colonia.nombre[0..3] }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
    assert response_body.any? { |c| c['nombre'].include?(@colonia.nombre[0..3]) }
  end

  test "should filter search by estado" do
    get search_api_v1_colonias_url, params: { clave_estado: @estado.clave }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.all? { |c| c['municipio']['estado']['clave'] == @estado.clave }
  end

  test "should filter search by municipio" do
    get search_api_v1_colonias_url, params: { municipio_id: @municipio.id }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.all? { |c| c['municipio_id'] == @municipio.id }
  end
end
