window.addEventListener('message', function(event) {
    let data = event.data;

    if (data.type === "ui") {
        if (data.display === true) {
            document.body.style.display = "block";
        } else {
            document.body.style.display = "none";
        }
    }

    if (data.type === "updateStocks") {
        updateStockList(data.stocks);
    }
});

document.getElementById('close-button').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeNUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(() => {
        document.body.style.display = "none";
    }).catch(error => console.error('Error:', error));
});

document.getElementById('logout-button').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/closeNUI`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).then(() => {
        document.body.style.display = "none";
    }).catch(error => console.error('Error:', error));
});

document.getElementById('buy-button').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/buyStock`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(error => console.error('Error:', error));
});

document.getElementById('sell-button').addEventListener('click', function() {
    fetch(`https://${GetParentResourceName()}/sellStock`, {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify({})
    }).catch(error => console.error('Error:', error));
});

document.querySelectorAll('.category-button').forEach(button => {
    button.addEventListener('click', function() {
        let category = this.getAttribute('data-category');
        fetch(`https://${GetParentResourceName()}/filterStocks`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json'
            },
            body: JSON.stringify({ category: category })
        }).catch(error => console.error('Error:', error));
    });
});

function updateStockList(stocks) {
    const stockList = document.getElementById('stock-list');
    stockList.innerHTML = ''; // Clear existing stocks

    stocks.forEach(stock => {
        let stockItem = document.createElement('div');
        stockItem.className = 'stock-item';
        stockItem.innerText = `${stock.name}: $${stock.price}`;
        stockList.appendChild(stockItem);
    });
}
