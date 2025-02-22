module Api
  module V1
    class MunicipiosController < ApplicationController
      def index
        estado_clave = params[:estado_id] || params[:clave_estado]
        
        unless estado_clave.present?
          render json: { error: "estado_id or clave_estado parameter is required" }, status: :unprocessable_entity
          return
        end

        @estado = Estado.find_by!(clave: estado_clave)
        @municipios = @estado.municipios.order(Arel.sql("CAST(clave AS INTEGER)"))
        render json: @municipios, except: [:created_at, :updated_at]
      end

      def show
        estado_clave = params[:estado_id] || params[:clave_estado]
        
        unless estado_clave.present?
          render json: { error: "estado_id or clave_estado parameter is required" }, status: :unprocessable_entity
          return
        end

        @estado = Estado.find_by!(clave: estado_clave)
        @municipio = @estado.municipios.find_by!(clave: params[:id])
        render json: @municipio, include: [:estado, :colonias], except: [:created_at, :updated_at]
      end

      def search
        @municipios = Municipio.joins(:estado)
        
        @municipios = @municipios.where('municipios.nombre ILIKE ?', "%#{params[:q]}%") if params[:q].present?
        @municipios = @municipios.where(estados: { clave: params[:clave_estado] }) if params[:clave_estado].present?
        
        render json: @municipios, include: :estado, except: [:created_at, :updated_at]
      end

      private

      def set_estado
        @estado = Estado.find_by!(clave: params[:estado_id])
      end
    end
  end
end
