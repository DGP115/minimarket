import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu"]

  connect() {
    console.log("context-menu connected")
    this.boundHide = this.hide.bind(this)
    document.addEventListener("click", this.boundHide)
  }

  disconnect() {
    document.removeEventListener("click", this.boundHide)
  }

  contextmenu(event) {
    event.preventDefault()  // Prevent the browser's default context menu

    console.log("right-click detected")

    // Close any other open menus
    document.querySelectorAll("[data-context-menu-target='menu']").forEach(m => {
      m.classList.add("hidden")
    })

    // Position the menu at the cursor's location
    this.menuTarget.style.top = `${event.clientY}px`
    this.menuTarget.style.left = `${event.clientX}px`

    //Unhide the menu
    this.menuTarget.classList.remove("hidden")

    // Close on click outside
    document.addEventListener("click", this.closeMenu)

  }

  closeMenu = () => {
    this.menuTarget.classList.add("hidden")
    document.removeEventListener("click", this.closeMenu)
  }

  hide() {
    if (!this.menuTarget.classList.contains("hidden")) {
      this.menuTarget.classList.add("hidden")
    }
  }
}