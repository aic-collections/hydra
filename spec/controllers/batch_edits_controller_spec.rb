# frozen_string_literal: true
require 'rails_helper'

describe BatchEditsController do
  describe "#form_class" do
    subject { described_class.new }
    its(:form_class) { is_expected.to eq(BatchEditForm) }
  end

  describe "#destroy" do
    include_context "authenticated admin user"

    let(:destroy_params) do
      {
        method: "delete",
        commit: "delete selected",
        update_type: "delete_all",
        return_controller: "my/works",
        batch_document_ids: [image_asset.id]
      }
    end

    context "when the asset has relationships" do
      let!(:work) { create(:work) }

      let!(:image_asset) do
        create(:still_image_asset, user: user,
                                   title: ["Hello Title"],
                                   representation_of_uris: [work.uri])
      end

      before do
        post "destroy_collection", destroy_params
      end

      subject { flash[:error] }

      it { is_expected.to eq("These assets were not deleted because they have resources linking to them: #{image_asset.title.first}.") }
    end

    context "when the asset has no relationships" do
      let!(:image_asset) { create(:still_image_asset, user: user, title: ["Hello Title"]) }
      it "destroys the assets" do
        expect { post "destroy_collection", destroy_params }.to change { GenericWork.count }.by(-1)
      end
    end
  end

  describe "#update" do
    include_context "authenticated admin user"

    let(:asset1) { create(:department_asset) }
    let(:asset2) { create(:department_asset) }
    let(:asset3) { create(:registered_asset) }

    before { request.env["HTTP_REFERER"] = "where_i_came_from" }

    context "when changing visibility" do
      let(:parameters) do
        {
          update_type:        "update",
          generic_work:       { visibility: "authenticated" },
          batch_document_ids: [asset1.id, asset2.id]
        }
      end

      it "applies the new setting to all works" do
        expect(VisibilityCopyJob).to receive(:perform_later).twice
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(asset1.reload.visibility).to eq("authenticated")
        expect(asset2.reload.visibility).to eq("authenticated")
      end
    end

    context "when visibility is nil" do
      let(:parameters) do
        {
          update_type:        "update",
          generic_work:       {},
          batch_document_ids: [asset1.id, asset3.id]
        }
      end

      it "preserves the objects' original permissions" do
        expect(VisibilityCopyJob).not_to receive(:perform_later)
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(asset1.reload.visibility).to eq("department")
        expect(asset3.reload.visibility).to eq("authenticated")
      end
    end

    context "when visibility is unchanged" do
      let(:parameters) do
        {
          update_type:        "update",
          generic_work:       { visibility: "department" },
          batch_document_ids: [asset1.id, asset2.id]
        }
      end

      it "preserves the objects' original permissions" do
        expect(VisibilityCopyJob).not_to receive(:perform_later)
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(asset1.reload.visibility).to eq("department")
        expect(asset2.reload.visibility).to eq("department")
      end
    end

    context "when permissions are changed" do
      let(:group_permission) { { "0" => { type: "group", name: "newgroop", access: "edit" } } }
      let(:parameters) do
        {
          update_type:        "update",
          generic_work:       { permissions_attributes: group_permission },
          batch_document_ids: [asset1.id, asset2.id]
        }
      end

      it "updates the permissions on all the works" do
        expect(VisibilityCopyJob).not_to receive(:perform_later)
        expect(InheritPermissionsJob).to receive(:perform_later).twice
        put :update, parameters.as_json
        expect(asset1.reload.edit_groups).to include("newgroop")
        expect(asset2.reload.edit_groups).to include("newgroop")
      end
    end

    context "when passing embargo and lease information" do
      let(:parameters) do
        {
          update_type: "update",
          generic_work: {
            visibility: "open",
            visibility_during_embargo: "department",
            embargo_release_date: "2017-07-18",
            visibility_after_embargo: "open",
            visibility_during_lease: "open",
            lease_expiration_date: "2017-07-18",
            visibility_after_lease: "department"
          },
          batch_document_ids: [asset1.id, asset2.id]
        }
      end

      it "applies the new setting to all works" do
        expect(VisibilityCopyJob).to receive(:perform_later).twice
        expect(InheritPermissionsJob).not_to receive(:perform_later)
        put :update, parameters.as_json
        expect(asset1.reload.visibility).to eq("open")
        expect(asset2.reload.visibility).to eq("open")
        expect(asset1.reload.visibility_during_embargo).to be_nil
        expect(asset2.reload.visibility_during_embargo).to be_nil
      end
    end
  end

  describe "#edit" do
    include_context "authenticated saml user"

    context "with a bogus-id" do
      it "redirects to the user's dashboard" do
        get :edit, batch_document_ids: ["bogus-id"]
        expect(response).to be_not_found
      end
    end

    context "with a non-admin user" do
      let(:asset1) { create(:department_asset) }

      it "redirects to the user's dashboard" do
        get :edit, batch_document_ids: [asset1.id]
        expect(flash[:warning]).to eq("Batch edit is only permitted to administrators")
        expect(response).to be_redirect
      end
    end
  end
end
