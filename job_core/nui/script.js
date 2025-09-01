// script.js for job_core nui

const container = document.getElementById('container');

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === 'ui') {
        if (data.show) {
            container.style.display = 'block';
        } else {
            container.style.display = 'none';
        }
    }
});

// For development in browser:
// document.body.style.backgroundColor = '#555';
// container.style.display = 'block';
