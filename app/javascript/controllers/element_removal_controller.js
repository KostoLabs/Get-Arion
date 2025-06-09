import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="element-removal"
export default class extends Controller {
  connect() {
    setTimeout(() => this.remove(), 4000); // auto-remove après 4s
  }

  remove() {
    this.element.remove();
  }
}
