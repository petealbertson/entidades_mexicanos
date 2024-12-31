require "test_helper"

class Api::V1::MunicipiosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @estado = estados(:one)
    @municipio = municipios(:one)
  end

  test "should get index" do
    get api_v1_municipios_url
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
  end

  test "should get nested index" do
    get api_v1_estado_municipios_url(@estado.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert response_body.all? { |m| m['estado_id'] == @estado.id }
  end

  test "should get show with clave_estado" do
    get api_v1_municipio_url(@municipio.clave, clave_estado: @estado.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @municipio.nombre, response_body['nombre']
    assert_equal @municipio.clave, response_body['clave']
    assert_not_nil response_body['estado']
  end

  test "should get nested show" do
    get api_v1_estado_municipio_url(@estado.clave, @municipio.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @municipio.nombre, response_body['nombre']
    assert_equal @municipio.clave, response_body['clave']
  end

  test "should require clave_estado for direct show" do
    get api_v1_municipio_url(@municipio.clave)
    assert_response :unprocessable_entity
    
    response_body = JSON.parse(response.body)
    assert_includes response_body['error'], 'clave_estado'
  end

  test "should search municipios" do
    get search_api_v1_municipios_url, params: { q: @municipio.nombre[0..3] }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
    assert response_body.any? { |m| m['nombre'].include?(@municipio.nombre[0..3]) }
  end

  test "should filter search by estado" do
    get search_api_v1_municipios_url, params: { clave_estado: @estado.clave }
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert response_body.all? { |m| m['estado']['clave'] == @estado.clave }
  end
end
