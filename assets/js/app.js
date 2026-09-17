// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//
// If you have dependencies that try to import CSS, esbuild will generate a separate `app.css` file.
// To load it, simply add a second `<link>` to your `root.html.heex` file.

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import {hooks as colocatedHooks} from "phoenix-colocated/portfolio"
import topbar from "../vendor/topbar"

const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks},
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

// Universal Clipboard copy utility with instant floating toast notification
window.copyToClipboard = function(text, label = "Text") {
  const onSuccess = () => {
    window.showToast(`Copied ${label} to clipboard!`)
  }

  if (navigator.clipboard && window.isSecureContext) {
    navigator.clipboard.writeText(text)
      .then(onSuccess)
      .catch(() => copyFallback(text, onSuccess))
  } else {
    copyFallback(text, onSuccess)
  }
}

function copyFallback(text, onSuccess) {
  const textArea = document.createElement("textarea")
  textArea.value = text
  textArea.style.position = "fixed"
  textArea.style.left = "-999999px"
  textArea.style.top = "-999999px"
  document.body.appendChild(textArea)
  textArea.focus()
  textArea.select()
  try {
    const successful = document.execCommand("copy")
    if (successful && onSuccess) onSuccess()
  } catch (err) {
    console.error("Fallback copy failed", err)
  }
  textArea.remove()
}

// Global Floating Toast Notification
window.showToast = function(message) {
  let toastContainer = document.getElementById("toast-notification-container")
  if (!toastContainer) {
    toastContainer = document.createElement("div")
    toastContainer.id = "toast-notification-container"
    toastContainer.className = "fixed bottom-6 right-6 flex flex-col gap-2 pointer-events-none"
    toastContainer.style.zIndex = "99999"
    document.body.appendChild(toastContainer)
  }

  const toast = document.createElement("div")
  toast.className = "pointer-events-auto flex items-center gap-3 px-4 py-3 rounded-2xl bg-base-300 text-base-content shadow-2xl border border-emerald-500/50 backdrop-blur-xl text-xs sm:text-sm font-semibold transform transition-all duration-300 translate-y-4 opacity-0"
  toast.style.boxShadow = "0 10px 30px -5px rgba(0, 0, 0, 0.4), 0 0 15px rgba(16, 185, 129, 0.2)"
  toast.innerHTML = `
    <span class="flex size-7 rounded-full bg-emerald-500/20 text-emerald-400 items-center justify-center shrink-0">
      <svg class="size-4" viewBox="0 0 20 20" fill="currentColor">
        <path fill-rule="evenodd" d="M16.704 4.153a.75.75 0 0 1 .143 1.052l-8 10.5a.75.75 0 0 1-1.127.075l-4.5-4.5a.75.75 0 0 1 1.06-1.06l3.894 3.893 7.48-9.817a.75.75 0 0 1 1.05-.143Z" clip-rule="evenodd" />
      </svg>
    </span>
    <span class="pr-2 font-mono text-xs sm:text-sm">${message}</span>
  `

  toastContainer.appendChild(toast)

  requestAnimationFrame(() => {
    toast.classList.remove("translate-y-4", "opacity-0")
    toast.classList.add("translate-y-0", "opacity-100")
  })

  setTimeout(() => {
    toast.classList.remove("translate-y-0", "opacity-100")
    toast.classList.add("translate-y-4", "opacity-0")
    setTimeout(() => toast.remove(), 350)
  }, 3500)
}

// The lines below enable quality of life phoenix_live_reload
// development features:
//
//     1. stream server logs to the browser console
//     2. click on elements to jump to their definitions in your code editor
//
if (process.env.NODE_ENV === "development") {
  window.addEventListener("phx:live_reload:attached", ({detail: reloader}) => {
    // Enable server log streaming to client.
    // Disable with reloader.disableServerLogs()
    reloader.enableServerLogs()

    // Open configured PLUG_EDITOR at file:line of the clicked element's HEEx component
    //
    //   * click with "c" key pressed to open at caller location
    //   * click with "d" key pressed to open at function component definition location
    let keyDown
    window.addEventListener("keydown", e => keyDown = e.key)
    window.addEventListener("keyup", _e => keyDown = null)
    window.addEventListener("click", e => {
      if(keyDown === "c"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtCaller(e.target)
      } else if(keyDown === "d"){
        e.preventDefault()
        e.stopImmediatePropagation()
        reloader.openEditorAtDef(e.target)
      }
    }, true)

    window.liveReloader = reloader
  })
}

