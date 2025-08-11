$(document).ready(function() {
    function loadArtworks(artworks, playerArtworks) {
        $('#buyList').empty();
        $('#sellList').empty();
        $('#inspectList').empty();

        artworks.forEach(artwork => {
            $('#buyList').append(`
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    ${artwork.label} - $${artwork.price}
                    <button class="btn btn-success btn-sm buy-button" data-id="${artwork.id}"><i class="fas fa-shopping-cart"></i> Kaufen</button>
                </li>
            `);
        });

        playerArtworks.forEach(artwork => {
            $('#sellList').append(`
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    ${artwork.label} - $${Math.floor(artwork.price * 0.5)} (Verkaufspreis)
                    <button class="btn btn-warning btn-sm sell-button" data-id="${artwork.id}"><i class="fas fa-dollar-sign"></i> Verkaufen</button>
                </li>
            `);
            $('#inspectList').append(`
                <li class="list-group-item d-flex justify-content-between align-items-center">
                    ${artwork.label}
                    <button class="btn btn-info btn-sm inspect-button" data-id="${artwork.id}"><i class="fas fa-search"></i> Gutachten</button>
                </li>
            `);
        });
    }

    // Event-Listener für Kauf- und Verkaufsaktionen
    $('#buyList').on('click', '.buy-button', function() {
        let artworkId = $(this).data('id');
        $.post('https://kunsthandel-system/buy', JSON.stringify({ artworkId: artworkId }));
    });

    $('#sellList').on('click', '.sell-button', function() {
        let artworkId = $(this).data('id');
        $.post('https://kunsthandel-system/sell', JSON.stringify({ artworkId: artworkId }));
    });

    $('#inspectList').on('click', '.inspect-button', function() {
        let artworkId = $(this).data('id');
        $.post('https://kunsthandel-system/inspect', JSON.stringify({ artworkId: artworkId }));
    });

    $('#closeButton').click(function() {
        $.post('https://kunsthandel-system/close', JSON.stringify({}));
    });

    // NUI Callback für das Öffnen und Schließen des Menüs
    window.addEventListener('message', function(event) {
        if (event.data.type === 'openMarket') {
            loadArtworks(event.data.artworks, event.data.playerArtworks);
            $('#app').addClass('visible');
        } else if (event.data.type === 'close') {
            $('#app').removeClass('visible');
        }
    });
});