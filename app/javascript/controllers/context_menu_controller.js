import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "anchor"] // anchor is optional

  connect() {
    console.log("context-menu connected")
    // ensure we can hide on outside click
    this.onOutsideClick = this.onOutsideClick.bind(this)

  }

  // Bind this in markup: data-action="contextmenu->context-menu#open"
  open(event) {
    // Prevent the browser's default context menu
    event.preventDefault()

    // Close other menus
    document.querySelectorAll("[data-context-menu-target='menu']")
      .forEach(m => m.classList.add("hidden"))

    const anchor = this.hasAnchorTarget ? this.anchorTarget : this.element
    const rect = anchor.getBoundingClientRect()
    const menu = this.menuTarget

    // Use viewport coords to avoid parent positioning issues
    menu.style.position = "fixed"
    menu.style.top = `${rect.bottom}px`
    menu.style.left = `${rect.left + 10}px`

    // Show it, then clamp to viewport
    menu.classList.remove("hidden")

    const vw = window.innerWidth
    const vh = window.innerHeight
    const mr = menu.getBoundingClientRect()
    const pad = 8

    if (mr.right > vw) {
      menu.style.left = `${Math.max(pad, vw - mr.width - pad)}px`
    }
    if (mr.bottom > vh) {
      menu.style.top = `${Math.max(pad, vh - mr.height - pad)}px`
    }

    // Close on outside click / scroll / resize
    window.addEventListener("click", this.onOutsideClick, { once: true })
    window.addEventListener("scroll", this.hide, { once: true })
    window.addEventListener("resize", this.hide, { once: true })
  }

  onOutsideClick(e) {
    if (!this.menuTarget.contains(e.target)) this.hide()
  }

  hide = () => {
    this.menuTarget.classList.add("hidden")
  }
}