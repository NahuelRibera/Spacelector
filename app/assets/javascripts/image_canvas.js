// image_canvas.js

document.addEventListener("DOMContentLoaded", function() {
  const canvas = document.getElementById("imageCanvas");
  const context = canvas.getContext("2d");
  const compartmentNameInput = document.getElementById("compartmentName");
  const compartments = [];

  let isDrawing = false;
  let startX, startY, endX, endY;

  // Function to draw compartments on the canvas
  function drawCompartments() {
    context.clearRect(0, 0, canvas.width, canvas.height);
    compartments.forEach(compartment => {
      context.beginPath();
      context.rect(compartment.x, compartment.y, compartment.width, compartment.height);
      context.stroke();
      context.fillText(compartment.name, compartment.x, compartment.y - 5);
    });
  }

  // Function to save compartment data
  function saveCompartment() {
    const name = compartmentNameInput.value;
    const width = Math.abs(startX - endX);
    const height = Math.abs(startY - endY);
    compartments.push({ name: name, x: startX, y: startY, width: width, height: height });
    drawCompartments();
  }

  // Mouse event listeners
  canvas.addEventListener("mousedown", function(event) {
    isDrawing = true;
    startX = event.offsetX;
    startY = event.offsetY;
  });

  canvas.addEventListener("mousemove", function(event) {
    if (!isDrawing) return;
    endX = event.offsetX;
    endY = event.offsetY;
    drawCompartments();
    context.beginPath();
    context.rect(startX, startY, endX - startX, endY - startY);
    context.stroke();
  });

  canvas.addEventListener("mouseup", function(event) {
    isDrawing = false;
    saveCompartment();
  });
});
