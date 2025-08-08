window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "update") {
        document.getElementById("health-value").textContent = data.health + "%";
        document.getElementById("armor-value").textContent = data.armor + "%";
        document.getElementById("hunger-value").textContent = data.hunger + "%";
        document.getElementById("thirst-value").textContent = data.thirst + "%";
        document.getElementById("energy-value").textContent = data.energy + "%";
        document.getElementById("addiction-value").textContent = data.addiction + "%";
        document.getElementById("needs-value").textContent = data.needs + "%";
    }
});
