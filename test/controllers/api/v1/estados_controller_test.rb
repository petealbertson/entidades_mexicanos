require "test_helper"

class Api::V1::EstadosControllerTest < ActionDispatch::IntegrationTest
  setup do
    @estado = estados(:one)
  end

  test "should get index" do
    get api_v1_estados_url
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_kind_of Array, response_body
    assert_not_empty response_body
  end

  test "should get show" do
    get api_v1_estado_url(@estado.clave)
    assert_response :success
    
    response_body = JSON.parse(response.body)
    assert_equal @estado.nombre, response_body['nombre']
    assert_equal @estado.clave, response_body['clave']
    assert_equal @estado.abbreviation, response_body['abbreviation']
  end

  test "should return 404 for non-existent estado" do
    get api_v1_estado_url('nonexistent')
    assert_response :not_found
  end
end
