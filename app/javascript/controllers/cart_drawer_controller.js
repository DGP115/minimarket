import { Controller } from "@hotwired/stimulus"

export default class extends Controller {

  connect() {
    console.log("cart-drawer controller connected")

    this.show()  // auto-slide the cart_drawer when this stimulus controller is connected

  }

  show() {
    // Slide in the cart drawer
    console.log("cart-drawer controller show")

    // Force browser reflow to ensure transition triggers.  This is a goofy trick.
    // Without this, the transition doesn't happen because the class is removed too
    // quickly after the element is added to the DOM.
    // See https://stackoverflow.com/questions/24148403/trigger-css-transition-on-appended-element
    this.element.offsetHeight // read triggers reflow

    // Then remove translate-x-full so Tailwind animates it
    this.element.classList.remove("translate-x-full")
    this.element.classList.add("translate-x-0")

  }

  hide() {
    console.log("cart-drawer controller hide")
    this.element.classList.remove("translate-x-0")
    this.element.classList.add("translate-x-full")

    setTimeout(() => {
    this.element.remove() // completely remove from DOM
    }, 500)
  }
}