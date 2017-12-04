# frozen_string_literal: true
require 'rails_helper'

describe ParameterizedRelationships do
  let(:work1) { build(:work, citi_uid: "work1") }
  let(:work2) { build(:work, citi_uid: "work2") }

  subject { described_class.new(params) }

  context "when the parameters are invalid" do
    context "with no CITI type specified" do
      let(:params) { ActionController::Parameters.new(relationship: "documentation_for") }

      its(:representation_of_uris) { is_expected.to be_empty }
      its(:document_of_uris)       { is_expected.to be_empty }
    end

    context "with no relationship specified" do
      let(:params) { ActionController::Parameters.new(citi_type: "Work") }

      its(:representation_of_uris) { is_expected.to be_empty }
      its(:document_of_uris)       { is_expected.to be_empty }
    end

    context "when the citi_uid parameter is not an array" do
      let(:params) { ActionController::Parameters.new(citi_type: "Work",
                                                      relationship: "documentation_for",
                                                      citi_uid: "dne") }

      its(:representation_of_uris) { is_expected.to be_empty }
      its(:document_of_uris)       { is_expected.to be_empty }
    end
  end

  context "with non-existent CITI resources" do
    let(:params) { ActionController::Parameters.new(citi_type: "Work",
                                                    relationship: "documentation_for",
                                                    citi_uid: ["dne"]) }

    its(:representation_of_uris) { is_expected.to be_empty }
    its(:document_of_uris)       { is_expected.to be_empty }
  end

  context "with non-existent CITI types" do
    let(:params) { ActionController::Parameters.new(citi_type: "Bogus",
                                                    relationship: "documentation_for",
                                                    citi_uid: ["dne"]) }

    its(:representation_of_uris) { is_expected.to be_empty }
    its(:document_of_uris)       { is_expected.to be_empty }
  end

  context "with existing CITI resources" do
    before do
      allow(Work).to receive(:find_by_citi_uid).with("work1", with_solr: true).and_return(work1)
      allow(Work).to receive(:find_by_citi_uid).with("work2", with_solr: true).and_return(work2)
    end

    context "with representations" do
      let(:params) { ActionController::Parameters.new(relationship: "representation_for",
                                                      citi_type: "Work",
                                                      citi_uid: [work1.citi_uid, work2.citi_uid]) }

      its(:representation_of_uris) { is_expected.to contain_exactly(work1, work2) }
      its(:document_of_uris)       { is_expected.to be_empty }
    end

    context "with documents" do
      let(:params) { ActionController::Parameters.new(relationship: "documentation_for",
                                                      citi_type: "Work",
                                                      citi_uid: [work1.citi_uid, work2.citi_uid]) }

      its(:document_of_uris)       { is_expected.to contain_exactly(work1, work2) }
      its(:representation_of_uris) { is_expected.to be_empty }
    end
  end
end
