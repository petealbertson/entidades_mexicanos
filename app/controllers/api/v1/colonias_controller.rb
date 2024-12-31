module Api
  module V1
    class ColoniasController < ApplicationController
      before_action :set_municipio, except: [:index, :show, :search]

      def index
        if params[:municipio_id]
          @colonias = @municipio.colonias
        else
          @colonias = Colonia.all
        end
        render json: @colonias
      end

      def show
        unless params[:clave_estado].present?
          render json: { error: "clave_estado parameter is required" }, status: :unprocessable_entity
          return
        end

        @colonia = Colonia.joins(municipio: :estado)
                         .where(clave: params[:id])
                         .where(estados: { clave: params[:clave_estado] })
                         .first!

        render json: @colonia, include: { municipio: { include: :estado } }
      end

      def search
        @colonias = Colonia.joins(:municipio, municipio: :estado)
        
        @colonias = @colonias.where('colonias.nombre ILIKE ?', "%#{params[:q]}%") if params[:q].present?
        @colonias = @colonias.where(municipios: { estado_id: params[:estado_id] }) if params[:estado_id].present?
        @colonias = @colonias.where(municipio_id: params[:municipio_id]) if params[:municipio_id].present?
        
        render json: @colonias, include: { municipio: { include: :estado } }
      end

      private

      def set_municipio
        @estado = Estado.find_by!(clave: params[:estado_id])
        @municipio = @estado.municipios.find_by!(clave: params[:municipio_id])
      end
    end
  end
end
