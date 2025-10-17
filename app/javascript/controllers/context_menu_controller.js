import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["menu", "anchor"] // anchor is optional.  Recall it is the <div> to be used as basis for menu position

  connect() {
    console.log("context-menu connected")
    // ensure we can hide on outside click
    this.onOutsideClick = this.onOutsideClick.bind(this)

  }

  // Bind the "open" method below to a button in a view by including this in the CSS markup for teh button: 
  //  data-action="contextmenu->context-menu#open"
  //  In the above:
  //    - 'contextmenu' refers to the method name used by any browser to invoke a pop-up menu
  //                    By referring to it [in the view's butotn code], we are intercepting the browser's
  //                    default handling of that method and repalcing it with the below
  //    - 'context-menu' refers to this stimulus controller
  //    - #open refers to the method below
  open(event) {
    // Prevent the browser's default context menu
    event.preventDefault()

    // Close other menus
    document.querySelectorAll("[data-context-menu-target='menu']")
      .forEach(m => m.classList.add("hidden"))

    //  ------  Menu positioning ------
    // If provided, use "anchor" to set the position of the pop-up menu
    const anchor = this.hasAnchorTarget ? this.anchorTarget : this.element
    const rect = anchor.getBoundingClientRect()
    const menu = this.menuTarget

    // Use viewport coords to avoid parent positioning issues
    menu.style.position = "fixed"
    menu.style.top = `${rect.bottom}px`
    menu.style.left = `${rect.left + 20}px`

    // Show the menu, then clamp to viewport
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
    //  ------  Menu positioning end ------

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