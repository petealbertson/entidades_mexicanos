module Api
  module V1
    class MunicipiosController < ApplicationController
      include ::UmamiTrackable

      def index
        # Start with a base scope including the estado and ordered
        @municipios = Municipio.includes(:estado).order(Arel.sql("CAST(municipios.clave AS INTEGER)"))

        # Filter by estado if estado_id is provided (from nested route)
        if params[:estado_id].present?
          @estado = Estado.find_by(clave: params[:estado_id])
          if @estado
            @municipios = @municipios.where(estado: @estado)
          else
            render json: { error: "Estado not found with clave: #{params[:estado_id]}" }, status: :not_found
            return # Stop further processing if estado not found
          end
        end

        # Filter by search query if q parameter is present
        if params[:q].present?
          @municipios = @municipios.where('municipios.nombre ILIKE ?', "%#{params[:q]}%")
        end
        
        # Render the result, including the estado
        render json: @municipios, include: :estado, except: [:created_at, :updated_at]
      end

      def show
        # Keep existing logic, it already handles finding estado if needed
        estado_clave = params[:estado_id] # Use estado_id if nested
        
        if estado_clave.present?
          @estado = Estado.find_by!(clave: estado_clave)
          @municipio = @estado.municipios.find_by!(clave: params[:id])
        else
          # Find municipio directly if not nested (uses primary key 'id' for municipio lookup)
          # Or adjust if you want /municipios/:id route to use 'clave' as well.
          # Assuming standard Rails find by primary key for non-nested /municipios/:id
          @municipio = Municipio.includes(:estado).find(params[:id]) 
        end

        render json: @municipio, include: [:estado, :colonias], except: [:created_at, :updated_at]

      rescue ActiveRecord::RecordNotFound
        # Handle cases where Estado or Municipio is not found
         render json: { error: "Record not found" }, status: :not_found
      end
    end
  end
end
