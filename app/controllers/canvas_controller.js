// canvas_controller.js
import { Controller } from 'stimulus';
import fabric from 'fabric';

export default class extends Controller {
  enterDrawingMode() {
    // Assuming 'myCanvas' is the correct ID of your canvas element
    const canvas = new fabric.Canvas('myCanvas');

    // Enable drawing mode
    canvas.isDrawingMode = true;

    // Set drawing properties
    canvas.freeDrawingBrush.width = 5;
    canvas.freeDrawingBrush.color = 'red';

    // Add event listener to handle box creation
    canvas.on('path:created', function (options) {
      // Handle the creation of boxes here
      console.log(options.path);
    });
  }
}
