window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "update") {
        // This is the logic for the PLAYER HUD
        const statuses = {
            health: { value: data.health, low_threshold: 25 },
            armor: { value: data.armor },
            hunger: { value: data.hunger, low_threshold: 25 },
            thirst: { value: data.thirst },
            addiction: { value: data.addiction, max: 100 },
            temperature: { value: data.temperature, min: -10, max: 45 }
        };

        for (const [name, props] of Object.entries(statuses)) {
            const element = document.getElementById(name);
            if (!element) continue;

            const progress = document.getElementById(`${name}-progress`);
            const valueText = document.getElementById(`${name}-value`);

            if (valueText) {
                valueText.textContent = Math.floor(props.value);
            }

            if (progress) {
                let percentage = props.value;
                if (name === 'temperature') {
                    percentage = ((props.value - props.min) / (props.max - props.min)) * 100;
                } else if (name === 'addiction') {
                    percentage = (props.value / props.max) * 100;
                }
                const angle = (Math.min(percentage, 100) / 100) * 360;
                progress.style.background = `conic-gradient(var(--${name}-color) ${angle}deg, transparent ${angle}deg)`;
            }

            if (props.low_threshold) {
                if (props.value <= props.low_threshold) {
                    element.classList.add(`low-${name}`);
                } else {
                    element.classList.remove(`low-${name}`);
                }
            }
        }
    } else if (data.type === "showVehicle") {
        // This is the logic to SHOW/HIDE the vehicle hud
        const vehicleHud = document.getElementById('vehicle-hud-container');
        if (data.show) {
            vehicleHud.classList.add('visible');
        } else {
            vehicleHud.classList.remove('visible');
        }
    } else if (data.type === "updateVehicle") {
        // This is the logic to UPDATE the vehicle hud
        const speedArc = document.getElementById('speed-arc');
        const speedNeedle = document.getElementById('speed-needle');
        const speedValue = document.getElementById('speed-value');
        const fuelValue = document.getElementById('fuel-value');
        const engineValue = document.getElementById('engine-value');

        const maxSpeed = 250; // Max speed in km/h for the gauge
        const speed_percent = Math.min(data.speed / maxSpeed, 1);

        // Update Arc
        const speedAngle = speed_percent * 270;
        if (speedArc) {
            speedArc.style.setProperty('--speed-angle', `${speedAngle}deg`);
        }

        // Update Needle
        const needleRotation = (speed_percent * 270) - 135; // Map to -135deg to +135deg range
        if (speedNeedle) {
            speedNeedle.style.transform = `rotate(${needleRotation}deg)`;
        }

        if (speedValue) {
            speedValue.textContent = data.speed;
        }
        if (fuelValue) {
            fuelValue.textContent = data.fuel;
        }
        if (engineValue) {
            engineValue.textContent = data.engineHealth;
        }
    }
});
