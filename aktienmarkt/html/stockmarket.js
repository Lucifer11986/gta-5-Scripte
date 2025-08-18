// stockmarket.js

window.addEventListener('message', function(event) {
    if (event.data.action === 'showStockMarket') {
        document.getElementById('stockMarket').classList.remove('hidden');
        fetchStocks();
    } else if (event.data.action === 'updateStocks') {
        updateStockList(event.data.stocks);
    }
});

function closeMenu() {
    document.getElementById('stockMarket').classList.add('hidden');
    $.post('http://your_resource_name/closeMenu', JSON.stringify({}));
}

function fetchStocks() {
    $.post('http://your_resource_name/getStocks', JSON.stringify({}));
}

function updateStockList(stocks) {
    const stockList = document.getElementById('stockList');
    stockList.innerHTML = '';

    stocks.forEach(stock => {
        const stockItem = document.createElement('div');
        stockItem.className = 'stock-item';
        stockItem.innerHTML = `
            <div>Name: ${stock.name}</div>
            <div>Preis: $${stock.price.toFixed(2)}</div>
            <button onclick="buyStock(${stock.id})">Kaufen</button>
            <button onclick="sellStock(${stock.id})">Verkaufen</button>
        `;
        stockList.appendChild(stockItem);
    });
}

function buyStock(stockId) {
    const amount = prompt('Wie viele Aktien möchten Sie kaufen?');
    if (amount) {
        $.post('http://your_resource_name/buyStock', JSON.stringify({
            stockId: stockId,
            amount: parseInt(amount)
        }));
    }
}

function sellStock(stockId) {
    const amount = prompt('Wie viele Aktien möchten Sie verkaufen?');
    if (amount) {
        $.post('http://your_resource_name/sellStock', JSON.stringify({
            stockId: stockId,
            amount: parseInt(amount)
        }));
    }
}
