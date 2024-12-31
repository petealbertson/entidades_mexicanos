module Api
  module V1
    class EstadosController < ApplicationController
      def index
        @estados = Estado.all
        render json: @estados
      end

      def show
        @estado = Estado.find_by!(clave: params[:id])
        render json: @estado, include: :municipios
      end
    end
  end
end
