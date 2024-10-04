import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    this.clicks = []
    // declaring idle time of 4 seconds to send batch request
    this.debounceTime = 4000
    this.debounceTimeout = null
    clearTimeout(this.debounceTimeout)

    this.element.querySelectorAll('a').forEach(link => {
      link.addEventListener('click', (event) => this.queueClick(event, link))
    })

    // Sending all remaining clicks when user leaves the page
    window.addEventListener("beforeunload", () => this.sendBatch())
  }

  queueClick(event, link){
    event.preventDefault()

    let url = link.getAttribute("href")
    if (url.startsWith("/"))
      url = window.location.origin + url

    const anchorText = link.textContent
    const timeStamp = new Date().toISOString()

    // Add click to batch
    this.clicks.push({
      anchor_text: anchorText,
      referrer: window.location.href,
      created_at: timeStamp,
      updated_at: timeStamp,
      url: url,
      user_agent: navigator.userAgent
    })

    // Handle link navigation
    this.navigateToLink(url, link.getAttribute("target") === "_blank")

    // Clear the previous debounce timer and set a new one
    clearTimeout(this.debounceTimeout)
    this.debounceTimeout = setTimeout(() => this.sendBatch(), this.debounceTime)
  }

  async sendBatch() {
    if (this.clicks.length === 0) return;

    const token = document.querySelector('meta[name="csrf-token"]').getAttribute('content')
    // use sendBeacon to do async requests
    if (navigator.sendBeacon) {
      console.log("--Sending Beacon Request--")
      const request_blob = new Blob(
          [JSON.stringify ({ link_click: this.clicks, authenticity_token: token} )],
          { type: 'application/json' }
      );
      navigator.sendBeacon("/link_clicks", request_blob)
      this.clicks = []
      return;
    }

    // fallback approach if sendBeacon is not supported
    const response = await fetch("/link_clicks", {
      method: "POST",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": token
      },
      body: JSON.stringify({ link_click: this.clicks }),
      keepalive: true
    });
    this.handleSendBatchResponse(response);

    // Clear clicks after sending
    this.clicks = [];
  }

  async handleSendBatchResponse(response) {
    switch (response.status) {
      case 422:
        const errors = await response.json()
        console.error("Validation errors on batch click tracking:", errors)
        break
      default:
        if (response.status === 200) break

        console.error(`Unexpected response status: ${response.status}`)
    }
  }

  navigateToLink(url, isExternal) {
    if (isExternal) {
      window.open(url, '_blank')
    } else {
      window.location.href = url
    }
  }
}
