require "open-uri"

module Api
  class PappersController < ApplicationController
    include ActionController::MimeResponds

    skip_before_action :verify_authenticity_token, if: -> { defined?(verify_authenticity_token) }
    skip_before_action :authenticate_user!, if: -> { defined?(authenticate_user!) }

    def search
      siren = params[:siren]&.strip
      Rails.logger.info "Recherche pour SIREN: #{siren}"
      return render json: { error: "Veuillez saisir un numéro SIREN" }, status: :bad_request if siren.blank?

      siren = siren.gsub(/\D/, '')
      unless siren.match?(/^\d{9}$/)
        return render json: {
          error: "Format SIREN invalide - un SIREN doit contenir exactement 9 chiffres"
        }, status: :bad_request
      end

      begin
        api_key = ENV['PAPPERS_API_KEY']
        if api_key.blank?
          return render json: { error: "Configuration API incomplète" }, status: :internal_server_error
        end

        existing_record = ApiPappers.find_by(siren: siren)
        if existing_record && existing_record.updated_at > 30.days.ago
          data = existing_record.response_data
        else
          uri_string = "https://api.pappers.fr/v2/entreprise?api_token=#{api_key}&siren=#{siren}"

          response = URI.open(uri_string, read_timeout: 10).read
          data = JSON.parse(response)

          record = ApiPappers.find_or_initialize_by(siren: siren)
          record.response_data = data
          record.save!
        end

        entreprise = data.key?("entreprise") ? data["entreprise"] : data

        company_name = entreprise["nom_entreprise"] || entreprise["denomination"] || "Non disponible"
        company_address = entreprise.dig("siege", "adresse_ligne_1") ||
                         entreprise.dig("siege", "adresse") || "Adresse non disponible"
        company_postal_code = entreprise.dig("siege", "code_postal") || "Non disponible"
        company_city     = entreprise.dig("siege", "ville") || "Non disponible"
        company_naf = entreprise["activite_principale"] || entreprise["code_naf"] || "Non disponible"
        company_creation_date = entreprise["date_creation"] || "Non disponible"

        render json: {
          company_name: company_name,
          company_address: company_address,
          company_naf: company_naf,
          company_creation_date: company_creation_date,
          company_postal_code: company_postal_code,
          company_city: company_city
        }


      rescue OpenURI::HTTPError => e
        code = e.io.status.first.to_i
        message = case code
                  when 404
                    "Entreprise non trouvée - le SIREN #{siren} ne correspond à aucune entreprise"
                  when 401, 403
                    "Problème d'authentification avec l'API Pappers"
                  when 429
                    "Limite d'appels API atteinte, veuillez réessayer plus tard"
                  when 500..599
                    "Le service Pappers rencontre actuellement des difficultés"
                  else
                    "Erreur lors de la communication avec l'API Pappers (#{code})"
                  end

        Rails.logger.error "Erreur HTTP: #{code} - #{e.message}"
        render json: { error: message }, status: code

      rescue JSON::ParserError => e
        Rails.logger.error "Erreur JSON: #{e.message}"
        render json: { error: "La réponse de l'API est invalide ou mal formatée" }, status: :internal_server_error

      rescue Timeout::Error, Errno::ECONNREFUSED => e
        Rails.logger.error "Erreur de connexion: #{e.class} - #{e.message}"
        render json: { error: "Impossible de se connecter à l'API Pappers, veuillez réessayer plus tard" }, status: :service_unavailable

      rescue => e
        Rails.logger.error "Exception: #{e.class} - #{e.message}"
        Rails.logger.error e.backtrace.join("\n")
        render json: { error: "Une erreur inattendue est survenue lors de la recherche" }, status: :internal_server_error
      end
    end
  end
end
