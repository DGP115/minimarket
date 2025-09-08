import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["rowQuantity", "bulkQuantity", "purchaseCell"]

  connect() {
    console.log("cart-bulk controller connected")
    // Confirm targets exist
    console.log(this.rowQuantityTargets)

    this.updatehiddenFields()
  }

  updatehiddenFields() {
    // The cart form has hidden fields accessed by "Update & Close"
    // Keep the hidden quantity fields in sync with hidden bulk fields
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
    console.log("cart-bulk controller recalculate called")
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
    console.log("cart-bulk controller recalculateBeforeSubmit called")
    this.recalculate()
    // no preventDefault so → form submits as usal to Rail controller given by route
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

  deleteItem(event) {
    console.log("cart-bulk controller deleteItem called")
    const id = event.currentTarget.dataset.itemId;

    if (!confirm("Are you sure you want to delete this item?")) return;

    const token = document.querySelector('meta[name="csrf-token"]').content;

    // This instructs Rails to invoke the relevant controller's delete method
    fetch(`/cart_items/${id}`, {
      method: "DELETE",
      headers: {
        "X-CSRF-Token": token,
        "Accept": "application/json" // ensures Rails responds appropriately
      }
    })
    .then((response) => {
      if (!response.ok) throw new Error(`Delete failed: ${response.status}`);

      // No error so remove the row from the DOM
      const row = document.getElementById(`cart_item_${id}`);
      if (row) row.remove();
      // Recalculate totals
      this.updateTotals();
    })
    .catch((error) => console.error(error));
  }

}