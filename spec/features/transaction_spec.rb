require 'rails_helper'

describe "CITI transactions" do

  let(:user) { FactoryGirl.create(:user) }

  before { load_fedora_fixture(fedora_fixture("transaction.ttl")) }

  context "when viewing" do
    before { visit(root_path) }
    it "shows all the information about the resource" do
      fill_in("q", with: "TR-123456")
      click_button("Go")
      click_link("TR-123456")
      within("dl") do
        expect(page).to have_content("TR-123456")
        expect(page).to have_content("2004-01-01T00:00Z ")
        click_link("http://definitions.artic.edu/ontology/1.0/status/active")
      end
      within("#show_actions") { expect(page).not_to have_content("Edit") }
    end
  end

  context "when editing" do
    let!(:asset) do
      GenericFile.create.tap do |f|
        f.apply_depositor_metadata(user)
        f.assert_still_image
        f.title = ["Fixture work"]
        f.save
      end
    end

    before do
      sign_in(user)
      visit(catalog_index_path)
    end
    
    it "only adds resources" do
      click_link("TR-123456")
      click_link("Edit")
      fill_in("transaction[document_ids][]", with: asset.id)
      fill_in("transaction[representation_ids][]", with: asset.id)
      fill_in("transaction[preferred_representation_ids][]", with: asset.id)
      click_button("Update Transaction")
      expect(first(:field, "transaction[document_ids][]").value).to eql asset.id
      expect(first(:field, "transaction[representation_ids][]").value).to eql asset.id
      expect(first(:field, "transaction[preferred_representation_ids][]").value).to eql asset.id
      click_link("View Transaction")
      expect(page).to have_content("Representations")
      expect(page).to have_content("Preferred Representations")
      expect(page).to have_content("Documents")

    end
  end

end