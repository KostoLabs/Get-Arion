require "test_helper"

class Import::ConfirmsControllerTest < ActionDispatch::IntegrationTest
  setup do
    sign_in @user = users(:family_admin)
  end

  test "affiche la page si les données sont nettoyées" do
    import = imports(:transaction)

    TransactionImport.any_instance.stubs(:cleaned?).returns(true)

    get import_confirm_path(import)
    assert_response :success
  end

  test "redirige si les données ne sont pas nettoyées" do
    import = imports(:transaction)

    TransactionImport.any_instance.stubs(:cleaned?).returns(false)

    get import_confirm_path(import)
    assert_redirected_to import_clean_path(import)
    assert_equal "Vous avez des données invalides, veuillez corriger toutes les erreurs avant de continuer", flash[:alert]
  end
end
