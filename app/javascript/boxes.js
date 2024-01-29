// app/assets/javascripts/boxes.js.erb
document.addEventListener('DOMContentLoaded', function() {
  const newBoxForm = document.querySelector('.new-box-form');

  if (newBoxForm) {
    newBoxForm.addEventListener('ajax:success', function(event) {
      const [data, status, xhr] = event.detail;
      const boxesContainer = document.getElementById('boxes-container');
      boxesContainer.insertAdjacentHTML('beforeend', data);
    });
  }
});
