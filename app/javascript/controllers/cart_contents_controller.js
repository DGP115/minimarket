import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowQuantity", "purchaseCell"]

  connect() {
    console.log("cart-contents controller connected")

    // Watch quantity inputs for recalculation
    this.rowQuantityTargets.forEach((input) => {
      input.addEventListener("input", () => this.recalculate())
    })
    // Run initial totals
    this.recalculate()
  }

  

  // Triggered by the listener on quantity inputs defined above
  recalculate() {
    console.log("cart-contents controller recalculate called")
    this.rowQuantityTargets.forEach((input, idx) => {
      const row = input.closest("[id^='cart_item']")
      // NOTE:  Items deleted by user are only marked with hidden _delete, 
      //        for later deletion in the cart_itemns_controller.
      //        So, skip hidden rows when computing totals
      if (this.isMarkedForDestroy(row)) return

      const price = parseFloat(row.dataset.price) || 0
      const qty = parseInt(input.value, 10) || 0
      const purchaseCell = this.purchaseCellTargets[idx]

      purchaseCell.textContent = this.formatCurrency(price * qty)

    })
    this.updateTotals()
  }

  // Triggered by "Update & Close" button before form submit
  recalculateBeforeSubmit() {
    console.log("cart-contents controller recalculateBeforeSubmit called")
    this.recalculate()
    // no preventDefault so → form submits as usual to Rails controller given by route
  }

  // Compute totals across all rows of cart
  updateTotals() {
    let totalPrice = 0
    let totalQuantity = 0

    this.rowQuantityTargets.forEach((input) => {
      const row = input.closest("[id^='cart_item']")
      // NOTE:  Items deleted by user are only marked with hidden _delete, 
      //        for later deletion in the cart_itemns_controller skip deleted rows.
      //        So, skip hidden rows when computing totals
      if (this.isMarkedForDestroy(row)) return

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

  deleteItem(event) {
    console.log("cart-contents controller deleteItem called")
    const row = event.currentTarget.closest("[id^='cart_item_']");

    if (!row) return;

    if (!confirm("Are you sure you want to delete this item?")) return;

    // mark _destroy checkbox as checked
    const destroyField = row.querySelector("input.destroy-flag");
    if (destroyField) destroyField.checked = true;

    // hide the row so the user sees it as deleted
    row.style.display = "none";
  }

  // Helper: detect if a row is flagged for deletion
  isMarkedForDestroy(row) {
    if (!row) return false
    const destroyField = row.querySelector("input.destroy-flag")
    return destroyField && destroyField.checked
  }

}