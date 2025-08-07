//  Toggles the display of (product category) hierarchies)

import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["children", "toggle"]

  connect() {
    this.expanded = false  // collaprse tree by default

    // Restore expanded state from localStorage
    this.toggleTargets.forEach(toggleBtn => {
      const id = toggleBtn.dataset.id
      if (this.isExpanded(id)) {
        this.expandNode(toggleBtn)
      }
    })
  }

  toggle(event) {
    const toggleBtn = event.currentTarget
    const id = toggleBtn.dataset.id
    const li = toggleBtn.closest("li")
    const children = li.querySelector("[data-tree-target='children']")

    if (!children) return

    const isHidden = children.classList.contains("hidden")

    children.classList.toggle("hidden")
    toggleBtn.textContent = isHidden ? "▼" : "▶"
    toggleBtn.setAttribute("aria-expanded", isHidden)

    // Save state to localStorage
    this.setExpanded(id, isHidden)
  }

  toggleAll(event) {
    this.expanded = !this.expanded
    const expandAll = this.expanded

    this.childrenTargets.forEach(children => {
      children.classList.toggle("hidden", !expandAll)
    })

    this.toggleTargets.forEach(btn => {
      btn.textContent = expandAll ? "▼" : "▶"
      btn.setAttribute("aria-expanded", expandAll)
      const id = btn.dataset.id
      this.setExpanded(id, expandAll)
    })

    // Update the button label
    event.currentTarget.textContent = expandAll ? "Collapse All" : "Show All"
  }

  // === LocalStorage helpers ===
  isExpanded(id) {
    return localStorage.getItem(this.key(id)) === "true"
  }

  setExpanded(id, value) {
    localStorage.setItem(this.key(id), value)
  }

  key(id) {
    return `category-expanded-${id}`
  }

  expandNode(btn) {
    const li = btn.closest("li")
    const children = li.querySelector("[data-tree-target='children']")
    if (children) {
      children.classList.remove("hidden")
      btn.textContent = "▼"
      btn.setAttribute("aria-expanded", true)
    }
  }

}