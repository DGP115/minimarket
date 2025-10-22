import { Controller } from "@hotwired/stimulus"

// Notes:
//  1.  Stimulus scopes controller data per element, so this.element is unique to each dropdown.
//  2.  Click-away is managed individually.

// Connects to data-controller="dropdown"

export default class extends Controller {
  static targets = ["menu", "hidden"]

// re:   static targets = ["menu", "hidden"]
//  This tells Stimulus:
// 	- “Inside any element with data-controller="dropdown", I expect to find data-dropdown-target="menu" 
//    and optionally data-dropdown-target="hidden".”
//  - That means in the controller code:
// 	    - this.menuTarget → the <ul> dropdown list
// 	    - this.hiddenTarget → the hidden field to write the selection to
//      - this.hasHiddenTarget → a boolean Stimulus gives you automatically

  connect() {
    console.log("Dropdown controller connected")
    this.handleClickOutside = this.handleClickOutside.bind(this)
  }

  // Toggle menu opened/closed
  toggle(event) {
    event.stopPropagation()
    if (this.menuTarget.classList.contains("hidden")) {
      this.open()
    } else {
      this.close()
    }
  }

  // Open the menu
  open() {
    this.menuTarget.classList.remove("hidden", "opacity-0", "scale-95")
    this.menuTarget.classList.add("opacity-100", "scale-100")
    document.addEventListener("click", this.handleClickOutside)
  }

  // Close the menu
  close() {
    this.menuTarget.classList.add("opacity-0", "scale-95")
    this.menuTarget.classList.remove("opacity-100", "scale-100")

    setTimeout(() => {
      this.menuTarget.classList.add("hidden")
    }, 200)
    document.removeEventListener("click", this.handleClickOutside)
  }

  // Close menu when clicking outside
  handleClickOutside(event) {
    if (!this.element.contains(event.target)) {
      this.close()
    }
  }

  // ===== Optional selection behavior for form dropdowns =====
  select(event) {
    event.preventDefault()
    const item = event.currentTarget
    const id = item.dataset.id
    const label = item.dataset.label

    // Update hidden input if present
    if (this.hasHiddenTarget) {
      this.hiddenTarget.value = id
    }

    // Update button label
    const button = this.element.querySelector("button span") || this.element.querySelector("button")
    if (button) button.textContent = label

    // Close the menu
    this.close()
  }
}