import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="gallery"
export default class extends Controller {
  static targets = ["thumbnail_enlarge"]
  connect() {
    console.log('Gallery controller connected');
  }

  thumbnail_enlarge() {
    // Set the 'src' or image to be displaed in the target -> 'thumbnail_enlarge' to be
    // the thumbnail image the user clicked
    this.thumbnail_enlargeTarget.src = event.currentTarget.src;
    
  }

}
