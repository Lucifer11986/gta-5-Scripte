// script.js for job_core nui

const container = document.getElementById('container');
const dispatchList = document.getElementById('dispatch-list');
const dutyList = document.getElementById('duty-list');

function renderDutyList(players) {
    dutyList.innerHTML = '';

    if (!players || players.length === 0) {
        dutyList.innerHTML = '<p>No players on duty.</p>';
        return;
    }

    players.forEach(player => {
        const playerDiv = document.createElement('div');
        playerDiv.className = 'duty-player';
        playerDiv.innerHTML = `<p>${player.name} [ID: ${player.source}]</p>`;
        dutyList.appendChild(playerDiv);
    });
}

function renderDispatch(calls) {
    // Clear the current list
    dispatchList.innerHTML = '';

    if (!calls || calls.length === 0) {
        dispatchList.innerHTML = '<p>No active calls.</p>';
        return;
    }

    // Sort calls by most recent first
    calls.sort((a, b) => b.id - a.id);

    calls.forEach(call => {
        const callDiv = document.createElement('div');
        callDiv.className = 'dispatch-call';

        const callTime = new Date(call.time * 1000).toLocaleTimeString();

        callDiv.innerHTML = `
            <p><strong>Call #${call.id}</strong></p>
            <p>${call.message}</p>
            <small>Received at: ${callTime} | Coords: ${call.coords.x.toFixed(2)}, ${call.coords.y.toFixed(2)}</small>
        `;
        dispatchList.appendChild(callDiv);
    });
}

window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.action === 'ui') {
        container.style.display = data.show ? 'block' : 'none';
    }

    if (data.action === 'dispatchUpdate') {
        renderDispatch(data.calls);
    }

    if (data.action === 'dutyUpdate') {
        renderDutyList(data.players);
    }
});

// Close the UI when Escape is pressed
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        container.style.display = 'none';
        // Send a message back to the client script to let it know the UI was closed
        fetch(`https://job_core/close`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json; charset=UTF-8',
            },
            body: JSON.stringify({})
        }).catch(err => console.log(err));
    }
});

// For development in browser:
// document.body.style.backgroundColor = '#555';
// container.style.display = 'block';
// renderDispatch([
//     {id: 1, message: 'Shots fired at Legion Square', coords: {x: 123.45, y: 678.90}, time: Math.floor(Date.now() / 1000)},
//     {id: 2, message: 'Suspicious vehicle near the bank', coords: {x: -50.0, y: 100.2}, time: Math.floor(Date.now() / 1000) - 120},
// ]);
