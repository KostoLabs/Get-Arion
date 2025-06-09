import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "sirenInput",
    "error",
    "results",
    "companyName",
    "companyAddress",
    "companyPostalCode",
    "companyCity",
    "companyNaf",
    "companyCreationDate",
    "submitButton"
  ];

  // Élément pour indiquer le chargement
  connect() {
    // Création d'un élément de spinner pour indiquer le chargement
    this.spinnerElement = document.createElement("div");
    this.spinnerElement.innerHTML = `
      <div class="flex justify-center items-center my-4">
        <div class="animate-spin rounded-full h-8 w-8 border-b-2 border-blue-500"></div>
        <span class="ml-2 text-gray-600">Recherche en cours...</span>
      </div>
    `;
    this.spinnerElement.classList.add("loading-spinner", "hidden");
    this.element.appendChild(this.spinnerElement);
  }

  // Méthode principale pour récupérer les données de l'entreprise
  async fetchCompanyData() {
    const siren = this.sirenInputTarget.value.trim();
    if (siren === "") return;

    try {
      console.log(`Recherche pour SIREN: ${siren}`);

      // Modification clé: ajout de .json à l'URL pour forcer le format JSON
      const response = await fetch(`/api/pappers/search.json?siren=${siren}`, {
        headers: {
          "Accept": "application/json",
          "X-Requested-With": "XMLHttpRequest"
        }
      });

      const contentType = response.headers.get("content-type");
      console.log(`Status: ${response.status}, Content-Type: ${contentType}`);

      if (!contentType || !contentType.includes("application/json")) {
        console.error("Réponse non-JSON reçue:", await response.text());
        throw new Error("Réponse invalide : le serveur n'a pas retourné du JSON.");
      }

      const data = await response.json();
      console.log("Réponse API complète:", data);

      if (response.status !== 200) {
        const errorMessage = data.error || `Erreur ${response.status}`;
        console.error("Erreur API:", errorMessage);
        this.showError(errorMessage);
        return;
      }

      if (data.error) {
        console.error("Erreur retournée par l'API:", data.error);
        this.showError(data.error);
        return;
      }

      this.hideError();
      this.showResults();

      this.companyNameTarget.value = data.company_name || "";
      this.companyAddressTarget.value = data.company_address || "";
      this.companyNafTarget.value = data.company_naf || "";
      this.companyCreationDateTarget.value = data.company_creation_date || "";
      this.companyPostalCodeTarget.value = data.company_postal_code || "";
      this.companyCityTarget.value = data.company_city || "";

      this.validateForm();

    } catch (error) {
      console.error("Erreur lors de la récupération des données:", error);
      this.showError(`Une erreur est survenue: ${error.message}`);
    }
  }

  // Méthodes auxiliaires pour la gestion de l'interface
  showError(message = "Aucune entreprise trouvée, merci de réessayer.") {
    this.errorTarget.classList.remove("hidden");
    this.errorTarget.textContent = message;
    this.resultsTarget.classList.add("hidden");
    this.submitButtonTarget.disabled = true;
  }

  hideError() {
    this.errorTarget.classList.add("hidden");
    this.errorTarget.textContent = "";
  }

  showResults() {
    this.resultsTarget.classList.remove("hidden");
  }

  showSpinner() {
    this.spinnerElement.classList.remove("hidden");
  }

  hideSpinner() {
    this.spinnerElement.classList.add("hidden");
  }

  validateForm() {
    const allFilled = this.companyNameTarget.value &&
                      this.companyAddressTarget.value &&
                      this.companyNafTarget.value &&
                      this.companyCreationDateTarget.value;

    this.submitButtonTarget.disabled = !allFilled;
  }
}
