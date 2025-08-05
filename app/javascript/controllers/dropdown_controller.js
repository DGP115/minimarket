import { Controller } from "@hotwired/stimulus"

// Notes:
//  1.  Stimulus scopes controller data per element, so this.element is unique to each dropdown.
//  2.  Click-away is managed individually.

// Connects to data-controller="dropdown"
export default class extends Controller {
  static targets = ["menu"]

  connect() {
    console.log("Dropdown controller connected")
    this.handleClickOutside = this.handleClickOutside.bind(this)
  }

  toggle(event) {
    event.stopPropagation()
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    }
    else {
      this.close()
    }
  }

  open() {
    this.menuTarget.classList.remove("hidden", "opacity-0", "scale-95")
    this.menuTarget.classList.add("opacity-100", "scale-100")
    document.addEventListener("click", this.handleClickOutside)
  }

  close() {
    this.menuTarget.classList.add("opacity-0", "scale-95")
    this.menuTarget.classList.remove("opacity-100", "scale-100")

    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 200)
    document.removeEventListener("click", this.handleClickOutside)
  }

  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }
}