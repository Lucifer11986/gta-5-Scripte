window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "update") {
        // --- Update Health ---
        const healthProgress = document.getElementById('health-progress');
        const healthValue = document.getElementById('health-value');
        const healthElement = document.getElementById('health');

        healthProgress.style.backgroundImage = `conic-gradient(var(--health-color) ${data.health * 3.6}deg, transparent 0deg)`;
        healthValue.textContent = data.health;

        if (data.health <= 25) {
            healthElement.classList.add('low-health');
        } else {
            healthElement.classList.remove('low-health');
        }

        // --- Update Armor ---
        const armorProgress = document.getElementById('armor-progress');
        const armorValue = document.getElementById('armor-value');

        armorProgress.style.backgroundImage = `conic-gradient(var(--armor-color) ${data.armor * 3.6}deg, transparent 0deg)`;
        armorValue.textContent = data.armor;

        // --- Update Hunger ---
        const hungerProgress = document.getElementById('hunger-progress');
        const hungerValue = document.getElementById('hunger-value');
        const hungerElement = document.getElementById('hunger');

        hungerProgress.style.backgroundImage = `conic-gradient(var(--hunger-color) ${data.hunger * 3.6}deg, transparent 0deg)`;
        hungerValue.textContent = data.hunger;

        if (data.hunger <= 25) {
            hungerElement.classList.add('low-hunger');
        } else {
            hungerElement.classList.remove('low-hunger');
        }

        // --- Update Thirst (Water Wave) ---
        const thirstWaves = document.querySelectorAll('#thirst-progress .wave');
        const thirstValue = document.getElementById('thirst-value');

        thirstValue.textContent = data.thirst;
        thirstWaves.forEach(wave => {
            // The 'bottom' property controls the fill level.
            // We subtract a bit to make sure 0% is fully empty.
            wave.style.bottom = `${data.thirst - 10}%`;
        });
    } else if (data.type === "showVehicle") {
        const vehicleHud = document.getElementById('vehicle-hud-container');
        if (data.show) {
            vehicleHud.style.display = 'flex';
        } else {
            vehicleHud.style.display = 'none';
        }
    } else if (data.type === "updateVehicle") {
        const speedArc = document.getElementById('speed-arc');
        const speedValue = document.getElementById('speed-value');
        const fuelValue = document.getElementById('fuel-value');
        const engineValue = document.getElementById('engine-value');

        // --- Update Speedometer Arc ---
        const maxSpeed = 250; // Max speed in km/h for the gauge
        const speed_percent = Math.min(data.speed / maxSpeed, 1);
        // Map speed percentage to a 270 degree range. The gradient starts at -45deg actual, so we map 0-1 to 0-270 degrees.
        const speedAngle = speed_percent * 270;

        // We use a CSS variable to pass the angle to the gradient
        speedArc.style.setProperty('--speed-angle', `${speedAngle}deg`);
        speedValue.textContent = data.speed;

        // --- Update Info ---
        fuelValue.textContent = data.fuel;
        engineValue.textContent = data.engineHealth;
    }
});
