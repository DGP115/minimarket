import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowQuantity", "bulkQuantity", "purchaseCell"]

  connect() {
    console.log("cart-bulk controller connected")
    // Keep visible quantity fields in sync with hidden bulk fields
    this.rowQuantityTargets.forEach((input) => {
      input.addEventListener("input", (e) => {
        const id = e.target.dataset.itemId
        const bulkInput = this.bulkQuantityTargets.find(
          (el) => el.dataset.bulkQuantityFor === id
        )
        if (bulkInput) bulkInput.value = e.target.value
      })
    })
  }

  // Triggered by "Recalculate" button
  recalculate() {
    this.rowQuantityTargets.forEach((input, idx) => {
      const row = input.closest("[id^='cart_item']")
      const price = parseFloat(row.dataset.price) || 0
      const qty = parseInt(input.value, 10) || 0
      const purchaseCell = this.purchaseCellTargets[idx]

      purchaseCell.textContent = this.formatCurrency(price * qty)

    })
    this.updateTotals()
  }

  // Triggered by "Update & Close" button before form submit
  recalculateBeforeSubmit(event) {
    this.recalculate()
    // no preventDefault so → form submits
  }

  // Compute totals across all rows of cart
  updateTotals() {
    let totalPrice = 0
    let totalQuantity = 0

    this.rowQuantityTargets.forEach((input) => {
      const row = input.closest("[id^='cart_item']")
      const price = parseFloat(row.dataset.price) || 0
      const qty = parseInt(input.value, 10) || 0
      
      totalPrice += price * qty
      totalQuantity += qty
    })
 
    // Update totals row in DOM
    const totalQtyEl = document.getElementById("cart-total-quantity")
    const totalPriceEl = document.getElementById("cart-total-price")

    if (totalQtyEl) totalQtyEl.textContent = totalQuantity
    if (totalPriceEl) totalPriceEl.textContent = this.formatCurrency(totalPrice)
  }
  
  // Utility for consistent formatting
  formatCurrency(amount) {
    return `$${amount.toFixed(2).replace(/\B(?=(\d{3})+(?!\d))/g, ",")}`
  }

}