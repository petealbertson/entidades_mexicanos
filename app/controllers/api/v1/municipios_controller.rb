module Api
  module V1
    class MunicipiosController < ApplicationController
      before_action :set_estado, except: [:index, :show, :search]

      def index
        if params[:estado_id]
          @municipios = @estado.municipios
        else
          @municipios = Municipio.all
        end
        render json: @municipios
      end

      def show
        if params[:estado_id]
          @municipio = @estado.municipios.find_by!(clave: params[:id])
        else
          unless params[:clave_estado].present?
            render json: { error: "clave_estado parameter is required" }, status: :unprocessable_entity
            return
          end

          @municipio = Municipio.joins(:estado)
                              .where(clave: params[:id])
                              .where(estados: { clave: params[:clave_estado] })
                              .first!
        end
        render json: @municipio, include: [:estado, :colonias]
      end

      def search
        @municipios = Municipio.joins(:estado)
        
        @municipios = @municipios.where('municipios.nombre ILIKE ?', "%#{params[:q]}%") if params[:q].present?
        @municipios = @municipios.where(estados: { clave: params[:clave_estado] }) if params[:clave_estado].present?
        
        render json: @municipios, include: :estado
      end

      private

      def set_estado
        @estado = Estado.find_by!(clave: params[:estado_id])
      end
    end
  end
end
