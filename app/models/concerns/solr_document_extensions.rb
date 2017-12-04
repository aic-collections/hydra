# frozen_string_literal: true
module SolrDocumentExtensions
  extend ActiveSupport::Concern
  include Permissions::Readable

  include SolrDocumentExtensions::Agent
  include SolrDocumentExtensions::Work
  include SolrDocumentExtensions::Exhibition
  include SolrDocumentExtensions::Place
  include SolrDocumentExtensions::Asset
  include SolrDocumentExtensions::Resource

  def pref_label
    Array(self[Solrizer.solr_name('pref_label', :stored_searchable)]).first
  end

  def citi_uid
    Array(self[Solrizer.solr_name('citi_uid', :symbol)]).first
  end

  def uid
    Array(self[Solrizer.solr_name('uid', :symbol)]).first
  end

  def status
    Array(self[Solrizer.solr_name('status', :stored_searchable)]).first
  end

  def fedora_uri
    ActiveFedora::Base.id_to_uri(id)
  end

  def aic_depositor
    Array(self[Solrizer.solr_name('aic_depositor', :symbol)]).first
  end

  def depositor_full_name
    Array(self[Solrizer.solr_name('depositor_full_name', :stored_searchable)]).first
  end

  def dept_created
    Array(self[Solrizer.solr_name('dept_created', :stored_searchable)]).first
  end

  def dept_created_citi_uid
    Array(self[Solrizer.solr_name('dept_created_citi_uid', :symbol)]).first
  end

  # Date/Time resource was modified in Fedora
  def modified_date
    date_field('system_modified')
  end

  def document_ids
    Array(self[Solrizer.solr_name('documents', :symbol)])
  end

  def document_of_ids
    Array(self[Solrizer.solr_name('document_of', :symbol)])
  end

  def representation_ids
    Array(self[Solrizer.solr_name('representations', :symbol)])
  end

  def representation_of_ids
    Array(self[Solrizer.solr_name('representation_of', :symbol)])
  end

  def preferred_representation_ids
    Array(self[Solrizer.solr_name('preferred_representation', :symbol)])
  end

  def preferred_representation_of_ids
    Array(self[Solrizer.solr_name('preferred_representation_of', :symbol)])
  end

  def preferred_representation_id
    preferred_representation_ids.first
  end

  def attachment_ids
    Array(self[Solrizer.solr_name('attachments', :symbol)])
  end

  def attachment_of_ids
    Array(self[Solrizer.solr_name('attachment_of', :symbol)])
  end

  def visibility
    @visibility ||= if read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_PUBLIC
                      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC
                    elsif read_groups.include? Hydra::AccessControls::AccessRight::PERMISSION_TEXT_VALUE_AUTHENTICATED
                      Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_AUTHENTICATED
                    else
                      Permissions::LakeshoreVisibility::VISIBILITY_TEXT_VALUE_DEPARTMENT
                    end
  end

  # Overrides CurationConcerns::SolrDocumentBehavior
  def title_or_label
    pref_label || title.join(', ')
  end

  def thumbnail_path
    Array(self['thumbnail_path_ss']).first
  end

  def nick
    Array(self[Solrizer.solr_name('nick', :stored_searchable)]).first
  end

  def family_name
    Array(self[Solrizer.solr_name('family_name', :stored_searchable)]).first
  end

  def given_name
    Array(self[Solrizer.solr_name('given_name', :stored_searchable)]).first
  end

  def rdf_types
    Array(self[Solrizer.solr_name('rdf_types', :symbol)])
  end
  alias type rdf_types

  def collection_type
    Array(self[Solrizer.solr_name('collection_type', :symbol)]).first
  end

  def related_image_id
    Array(self["hasRelatedImage_ssim"]).first
  end
end
