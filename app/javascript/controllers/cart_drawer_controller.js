import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("cart-drawer controller connected")
    this.show()  // auto-slide the cart_drawer when this stimulus controller is connected
  }

  show() {
    // Slide in
    this.element.classList.remove("translate-x-full")
    this.element.classList.add("translate-x-0")
  }

  hide() {
    this.element.classList.remove("translate-x-0")
    this.element.classList.add("translate-x-full")
  }

  animateOut(event) {
  //  When Turbo is about to render a new drawer, it fires turbo:before-stream-render.
  //  We intercept that, prevent immediate replacement, run the .hide() animation, then after 500ms (your Tailwind duration), we let Turbo continue.

    // Only act if this element is about to be replaced
    if (event.target.templateElement?.querySelector("#cart-drawer")) {
      // Prevent Turbo from instantly replacing
      event.preventDefault()

      // Animate out
      this.hide()

      // Wait for animation to finish, then resume render
      setTimeout(() => {
        event.detail.render()
      }, 700) // match your CSS transition duration
    }
  }
}