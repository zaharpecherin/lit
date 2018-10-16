module Lit
  class Api::V1::LocalizationsController < Api::V1::BaseController
    def index
      @localizations = fetch_localizations
      render json: @localizations.as_json(
        root: false,
        only: %i[id localization_key_id locale_id],
        methods: %i[value localization_key_str locale_str]
      )
    end

    def last_change
      @localization = Localization.order('updated_at DESC').first
      render json: @localization.as_json(
        root: false, only: [], methods: [:last_change]
      )
    end

    private

    def fetch_localizations
      if params[:after].present?
        after_date = Time.parse(params[:after])
        Localization.after(after_date).to_a
      else
        Localization.all
      end
    end
  end
end
