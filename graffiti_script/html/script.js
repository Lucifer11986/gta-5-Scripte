window.addEventListener('message', function(event) {
    if (event.data.action === "showMotifs") {
        const motifs = event.data.motifs;
        const motifList = document.getElementById('motif-list');
        motifList.innerHTML = '';

        for (let category in motifs) {
            const categoryHeader = document.createElement('h2');
            categoryHeader.innerText = category;
            motifList.appendChild(categoryHeader);

            motifs[category].forEach(motif => {
                const motifItem = document.createElement('div');
                motifItem.classList.add('motif-item');
                motifItem.innerText = motif.name;
                motifItem.onclick = function() {
                    const colors = prompt('Welche Farben möchtest du verwenden? (Komma getrennt)');
                    if (colors) {
                        const colorsArray = colors.split(',');
                        fetch(`https://${GetParentResourceName()}/selectMotif`, {
                            method: 'POST',
                            body: JSON.stringify({ motif: motif.file, colors: colorsArray })
                        });
                    }
                };
                motifList.appendChild(motifItem);
            });
        }
    }
});

document.getElementById('close-btn').onclick = function() {
    fetch(`https://${GetParentResourceName()}/closeUI`, {
        method: 'POST',
        body: JSON.stringify({})
    });
};
