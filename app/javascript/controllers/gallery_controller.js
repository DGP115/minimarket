import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["thumbnailEnlarge"]
  connect() {
    console.log('Gallery controller connected');

    // Store the default image source (original primary image)
    if (this.hasThumbnailEnlargeTarget) {
      this.defaultSrc = this.thumbnailEnlargeTarget.src
    }
  }

  thumbnailEnlarge() {
    // Set the 'src' or image to be displaed in the target -> 'thumbnail_enlarge' to be
    // the thumbnail image the user clicked
    this.thumbnailEnlargeTarget.src = event.currentTarget.src;
    
  }

  reset() {
    // Restore the original primary image
    if (this.defaultSrc) {
      this.thumbnailEnlargeTarget.src = this.defaultSrc
    }
  }

}
