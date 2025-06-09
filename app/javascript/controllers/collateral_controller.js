import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["haircut", "balance", "floor", "collateral"]

  connect() {
    this.setupBalanceListener()
    setTimeout(() => {
      this.calculate()
    }, 100)
  }

  setupBalanceListener() {
    const balanceField = document.querySelector('input[name*="[balance]"], input[name="account[balance]"]')
    if (balanceField && !this.hasBalanceTarget) {
      balanceField.addEventListener('input', () => {
        this.calculate()
      })
      this.balanceField = balanceField
    }
  }

  calculate() {
    if (!this.hasHaircutTarget || !this.hasFloorTarget) {
      return
    }

    const haircut = parseFloat(this.haircutTarget.value) || 0

    let balance = 0
    if (this.hasBalanceTarget) {
      balance = parseFloat(this.balanceTarget.value) || 0
    } else if (this.balanceField) {
      balance = parseFloat(this.balanceField.value) || 0
    } else {
      const balanceField = document.querySelector('input[name*="[balance]"], input[name="account[balance]"]')
      if (balanceField) {
        balance = parseFloat(balanceField.value) || 0
      }
    }

    let collateral = null
    if (this.hasCollateralTarget) {
      collateral = this.collateralTarget.value
    } else {
      const collateralSelect = this.element.querySelector('select[name*="[collateral]"]')
      if (collateralSelect) {
        collateral = collateralSelect.value
      }
    }

    const requiredCollaterals = ["real_estate", "inventory", "stocks", "materials", "invoices"]

    if (collateral && requiredCollaterals.includes(collateral)) {
      const calculated = balance * (haircut / 100)
      this.floorTarget.value = calculated.toFixed(2)
    } else {
      this.floorTarget.value = ""
    }
  }

  updateCollateral() {
    this.calculate()
  }

  updateHaircut() {
    this.calculate()
  }

  updateBalance() {
    this.calculate()
  }
}
