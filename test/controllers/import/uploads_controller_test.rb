require "test_helper"

class Import::UploadsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
    @import = imports(:transaction)
  end

  test "affiche la page d’upload" do
    get import_upload_url(@import)
    assert_response :success
  end

  test "charge un CSV valide via copier/coller" do
    patch import_upload_url(@import), params: {
      import: {
        raw_file_str: file_fixture("imports/valid.csv").read,
        col_sep: ","
      }
    }

    assert_redirected_to import_configuration_url(@import, template_hint: true)
    assert_equal "CSV chargé avec succès.", flash[:notice]
  end

  test "charge un CSV valide via fichier" do
    patch import_upload_url(@import), params: {
      import: {
        csv_file: file_fixture_upload("imports/valid.csv"),
        col_sep: ","
      }
    }

    assert_redirected_to import_configuration_url(@import, template_hint: true)
    assert_equal "CSV chargé avec succès.", flash[:notice]
  end

  test "échoue si le CSV est invalide" do
    patch import_upload_url(@import), params: {
      import: {
        csv_file: file_fixture_upload("imports/invalid.csv"),
        col_sep: ","
      }
    }

    assert_response :unprocessable_entity
    assert_equal "Le fichier CSV doit contenir des en-têtes et au moins une ligne de données.", flash[:alert]
  end
end
