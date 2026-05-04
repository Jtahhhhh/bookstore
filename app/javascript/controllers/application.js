import { Application } from "@hotwired/stimulus"

const application = Application.start()

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

export { application }

document.addEventListener("turbo:load", () => {
  const addButton = document.getElementById("add-order-item")
  const container = document.getElementById("order-items")
  const template = document.getElementById("order-item-template")

  if (!addButton || !container || !template) return

  addButton.addEventListener("click", () => {
    const uniqueId = new Date().getTime()
    const html = template.innerHTML.replaceAll("NEW_RECORD", uniqueId)

    container.insertAdjacentHTML("beforeend", html)
  })

  container.addEventListener("click", (event) => {
    if (event.target.classList.contains("remove-order-item")) {
      event.target.closest(".order-item-row").remove()
    }
  })
})