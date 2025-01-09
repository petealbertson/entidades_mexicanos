module Api
  module V1
    class ColoniasController < ApplicationController
      before_action :set_municipio, if: -> { params[:estado_id].present? && params[:municipio_id].present? }

      def index
        if params[:municipio_id]
          @colonias = @municipio.colonias.order(Arel.sql("CAST(clave AS INTEGER)"))
        else
          @colonias = Colonia.order(Arel.sql("CAST(clave AS INTEGER)"))
        end
        render json: @colonias, except: [:created_at, :updated_at]
      end

      def show
        if params[:municipio_id]
          @colonia = @municipio.colonias.find_by!(clave: params[:id])
          render json: @colonia, include: { municipio: { include: :estado } }, except: [:created_at, :updated_at]
        else
          unless params[:clave_estado].present?
            render json: { error: "clave_estado parameter is required" }, status: :unprocessable_entity
            return
          end

          @colonia = Colonia.joins(municipio: :estado)
                         .where(clave: params[:id])
                         .where(estados: { clave: params[:clave_estado] })
                         .first!

          render json: @colonia, include: { municipio: { include: :estado } }, except: [:created_at, :updated_at]
        end
      end

      def search
        @colonias = Colonia.joins(:municipio, municipio: :estado)
        
        @colonias = @colonias.where('colonias.nombre ILIKE ?', "%#{params[:q]}%") if params[:q].present?
        @colonias = @colonias.where(estados: { clave: params[:clave_estado] }) if params[:clave_estado].present?
        @colonias = @colonias.where(municipio_id: params[:municipio_id]) if params[:municipio_id].present?
        
        render json: @colonias, include: { municipio: { include: :estado } }, except: [:created_at, :updated_at]
      end

      private

      def set_municipio
        @estado = Estado.find_by!(clave: params[:estado_id])
        @municipio = @estado.municipios.find_by!(clave: params[:municipio_id])
      end
    end
  end
end
