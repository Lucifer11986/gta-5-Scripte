let sprayColor = null; // Will hold the color of the used spray can

window.addEventListener('message', function(event) {
    const item = event.data;
    if (item.action === "show") {
        const motifs = item.motifs;
        sprayColor = item.color; // Store the color
        const motifList = document.getElementById('motif-list');
        motifList.innerHTML = ''; // Clear previous list

        // Motifs are now a simple array of objects
        motifs.forEach(motif => {
            const motifItem = document.createElement('div');
            motifItem.classList.add('motif-item');
            motifItem.innerText = motif.name; // Display name

            motifItem.onclick = function() {
                // When a motif is selected, send the motif file and the stored color back to Lua
                fetch(`https://${GetParentResourceName()}/selectMotif`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify({
                        motif: motif.file, // Send the file name
                        color: sprayColor  // Send the stored color
                    })
                }).then(() => {
                    // Hide the UI after selection
                    document.body.style.display = 'none';
                });
            };
            motifList.appendChild(motifItem);
        });

        document.body.style.display = 'block'; // Show the UI
    }
});

// Close button functionality
document.getElementById('close-btn').onclick = function() {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json; charset=UTF-8' },
        body: JSON.stringify({})
    }).then(() => {
        document.body.style.display = 'none';
    });
};

// Also close with the Escape key
document.addEventListener('keydown', function(event) {
    if (event.key === 'Escape') {
        document.getElementById('close-btn').click();
    }
});
