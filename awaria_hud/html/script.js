window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "update") {
        document.getElementById("health-value").textContent = data.health + "%";
        document.getElementById("armor-value").textContent = data.armor + "%";
        document.getElementById("hunger-value").textContent = data.hunger + "%";
        document.getElementById("thirst-value").textContent = data.thirst + "%";
    }
});
