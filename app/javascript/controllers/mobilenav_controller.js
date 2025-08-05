import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
  console.log("mobilenav controller connected")
  }

  toggle() {
    console.log("Hamburger clicked") // <-- debug line

    const menu = this.menuTarget
    
    if (menu.classList.contains("hidden")) {
      // Show the menu
      menu.classList.remove("hidden")

      // Use requestAnimationFrame to allow layout to flush before animating
      requestAnimationFrame(() => {
        menu.classList.remove("opacity-0", "-translate-y-5")
        menu.classList.add("opacity-100", "translate-y-0")
      })
    } else {
      // Hide the menu
      menu.classList.remove("opacity-100", "translate-y-0")
      menu.classList.add("opacity-0", "-translate-y-5")

      setTimeout(() => {
        menu.classList.add("hidden")
      }, 300) // matches Tailwind transition duration
    }
  }
}