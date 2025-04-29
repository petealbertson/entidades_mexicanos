module Api
  module V1
    class ColoniasController < ApplicationController
      include ::UmamiTrackable

      def index
        @colonias = Colonia.includes(municipio: :estado).order(Arel.sql("CAST(colonias.clave AS INTEGER)"))

        if params[:estado_id].present? && params[:municipio_id].present?
          @estado = Estado.find_by(clave: params[:estado_id])
          unless @estado
            render json: { error: "Estado not found with clave: #{params[:estado_id]}" }, status: :not_found
            return
          end
          @municipio = @estado.municipios.find_by(clave: params[:municipio_id])
          unless @municipio
            render json: { error: "Municipio not found with clave: #{params[:municipio_id]} in Estado #{params[:estado_id]}" }, status: :not_found
            return
          end
          @colonias = @colonias.where(municipio: @municipio)
        end

        if params[:q].present?
          @colonias = @colonias.where('colonias.nombre ILIKE ?', "%#{params[:q]}%")
        end

        render json: @colonias, include: { municipio: { include: :estado } }, except: [:created_at, :updated_at]
      end

      def show
        if params[:estado_id].present? && params[:municipio_id].present?
          @estado = Estado.find_by!(clave: params[:estado_id])
          @municipio = @estado.municipios.find_by!(clave: params[:municipio_id])
          @colonia = @municipio.colonias.find_by!(clave: params[:id])
        else
          @colonia = Colonia.includes(municipio: :estado).find(params[:id])
        end

        render json: @colonia, include: { municipio: { include: :estado } }, except: [:created_at, :updated_at]

      rescue ActiveRecord::RecordNotFound
        render json: { error: "Record not found" }, status: :not_found
      end
    end
  end
end
