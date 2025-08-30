window.addEventListener('message', function(event) {
    const data = event.data;

    // Spieler-HUD Update
    if (data.type === "update") {
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

        // Jahreszeit im HUD anzeigen (zusätzlich zur Temperatur)
        if (data.season) {
            const seasonElement = document.getElementById("season-value");
            if (seasonElement) {
                seasonElement.textContent = data.season;
            }
        }
    }
});

// Fahrzeug-HUD Verwaltung
let vehicleHUDVisible = false;
let lastVehicleData = null;

window.addEventListener('message', function(event) {
    const data = event.data;

    if (data.type === "showVehicle") {
        vehicleHUDVisible = data.show;
        const vehicleHud = document.getElementById('vehicle-hud-container');
        if (vehicleHud) {
            vehicleHud.style.display = vehicleHUDVisible ? 'block' : 'none';
            if (vehicleHUDVisible && !window.ticksDrawn) {
                drawTicks();
                window.ticksDrawn = true;
            }
        }
    } 
    else if (data.type === "updateVehicle") {
        lastVehicleData = data; // Daten speichern
    }
});

// Fahrzeug-HUD kontinuierlich aktualisieren
setInterval(() => {
    if (!vehicleHUDVisible || !lastVehicleData) return;

    const data = lastVehicleData;
    const speedPercentMax = 250;
    const speed = Math.min(data.speed, speedPercentMax);
    const speedPercent = speed / speedPercentMax;

    // Nadel rotieren
    const needleRotation = (speedPercent * 270) - 135;
    const needle = document.getElementById('needle');
    if (needle) needle.setAttribute('transform', `translate(140 130) rotate(${needleRotation})`);

    // Speed Text
    const speedText = document.getElementById('speed-text');
    if (speedText) speedText.textContent = Math.floor(speed);

    // Tank- und Motoranzeige
    const fuelValue = document.getElementById('fuel-value');
    const engineValue = document.getElementById('engine-value');
    if (fuelValue) fuelValue.textContent = Math.floor(data.fuel);
    if (engineValue) engineValue.textContent = Math.floor(data.engineHealth);

}, 100); // 100ms Intervall = flüssiger

// Funktion: Tacho-Striche und Zahlen zeichnen
function drawTicks() {
    const ticksGroup = document.getElementById('ticks');
    if (!ticksGroup) return;

    const radius = 110;
    const startAngle = -135;
    const totalTicks = 27;
    const majorTickEvery = 3;

    ticksGroup.innerHTML = '';

    for (let i = 0; i <= totalTicks; i++) {
        const angleDeg = startAngle + (i * (270 / totalTicks));
        const angleRad = (angleDeg * Math.PI) / 180;

        const isMajor = (i % majorTickEvery) === 0;
        const tickLength = isMajor ? 15 : 7;
        const tickWidth = isMajor ? 3 : 1.5;

        const x1 = Math.cos(angleRad) * radius;
        const y1 = Math.sin(angleRad) * radius;
        const x2 = Math.cos(angleRad) * (radius - tickLength);
        const y2 = Math.sin(angleRad) * (radius - tickLength);

        const line = document.createElementNS("http://www.w3.org/2000/svg", "line");
        line.setAttribute('x1', x1.toString());
        line.setAttribute('y1', y1.toString());
        line.setAttribute('x2', x2.toString());
        line.setAttribute('y2', y2.toString());
        line.setAttribute('stroke', 'white');
        line.setAttribute('stroke-width', tickWidth.toString());
        ticksGroup.appendChild(line);

        if (isMajor) {
            const speedValue = Math.round((i * (250 / totalTicks)));
            const textRadius = radius - 30;
            const tx = Math.cos(angleRad) * textRadius;
            const ty = Math.sin(angleRad) * textRadius + 7;

            const text = document.createElementNS("http://www.w3.org/2000/svg", "text");
            text.setAttribute('x', tx.toString());
            text.setAttribute('y', ty.toString());
            text.setAttribute('fill', 'white');
            text.setAttribute('font-size', '16');
            text.setAttribute('font-family', 'Roboto, sans-serif');
            text.setAttribute('font-weight', '600');
            text.setAttribute('text-anchor', 'middle');
            text.textContent = speedValue.toString();
            ticksGroup.appendChild(text);
        }
    }
}
