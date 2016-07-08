# frozen_string_literal: true
class WorkPresenter < Sufia::WorkShowPresenter
  def self.model_terms
    [
      :artist,
      :creator_display,
      :credit_line,
      :date_display,
      :department,
      :dimensions_display,
      :earliest_year,
      :exhibition_history,
      :gallery_location,
      :inscriptions,
      :latest_year,
      :main_ref_number,
      :medium_display,
      :object_type,
      :place_of_origin,
      :provenance_text,
      :publication_history,
      :publ_ver_level
    ]
  end

  def self.terms
    model_terms + CitiResourceTerms.all
  end

  delegate(*terms, to: :solr_document)

  def title
    [pref_label]
  end

  def deleteable?
    current_ability.can?(:delete, Work)
  end

  def summary_terms
    [:uid, :main_ref_number, :created_by, :resource_created, :resource_updated]
  end
end
