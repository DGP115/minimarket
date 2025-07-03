import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="dismiss"
export default class extends Controller {
  static targets = ["dismissthis"];

  close() {
    this.dismissthisTarget.remove();
  }
  }

