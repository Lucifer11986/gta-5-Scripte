let selectedStock = null;

// NUI Message Listener
window.addEventListener('message', function(event) {
    const data = event.data;
    if (data.type === "ui") {
        document.body.style.display = data.display ? "flex" : "none";
    }
    if (data.type === "updateStocks") {
        updateStockList(data.stocks);
    }
    if (data.type === "updateMyStocks") {
        updateMyStockList(data.stocks);
    }
});

// Helper to send NUI callbacks
function post(event, data = {}) {
    fetch(`https://${GetParentResourceName()}/${event}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data)
    }).catch(error => console.error('Error:', error));
}

// Event Listeners
document.getElementById('close-button').addEventListener('click', () => post('closeNUI'));
document.getElementById('logout-button').addEventListener('click', () => post('closeNUI'));

document.querySelectorAll('.category-button').forEach(button => {
    button.addEventListener('click', function() {
        // Visually mark active category
        document.querySelectorAll('.category-button').forEach(btn => btn.classList.remove('active'));
        this.classList.add('active');
        post('filterStocks', { category: this.getAttribute('data-category') });
    });
});

document.getElementById('buy-button').addEventListener('click', () => {
    const amount = parseInt(document.getElementById('amount-input').value);
    if (selectedStock && amount > 0) {
        post('buyStock', { stockName: selectedStock.name, amount: amount });
    } else {
        console.log("No stock selected or invalid amount");
    }
});

document.getElementById('sell-button').addEventListener('click', () => {
    const amount = parseInt(document.getElementById('amount-input').value);
    if (selectedStock && amount > 0) {
        post('sellStock', { stockName: selectedStock.name, amount: amount });
    } else {
        console.log("No stock selected or invalid amount");
    }
});


// Functions to update UI
function updateStockList(stocks) {
    const stockList = document.getElementById('stock-list');
    stockList.innerHTML = '';
    stocks.forEach(stock => {
        const item = document.createElement('div');
        item.className = 'stock-item';
        item.innerHTML = `<span>${stock.label} (${stock.name.toUpperCase()})</span><span>$${stock.price}</span>`;
        item.onclick = () => {
            selectedStock = stock;
            // Highlight selected stock
            document.querySelectorAll('#stock-list .stock-item').forEach(el => el.classList.remove('selected'));
            item.classList.add('selected');
        };
        stockList.appendChild(item);
    });
}

function updateMyStockList(myStocks) {
    const myStockList = document.getElementById('my-stock-list');
    myStockList.innerHTML = '';
    if (myStocks && myStocks.length > 0) {
        myStocks.forEach(stock => {
            const item = document.createElement('div');
            item.className = 'stock-item';
            item.innerHTML = `<span>${stock.label} (${stock.stock_name.toUpperCase()})</span><span>${stock.amount}</span>`;
            // Optional: allow selecting owned stocks for selling
            item.onclick = () => {
                selectedStock = { name: stock.stock_name, label: stock.label, price: stock.price }; // creating a temporary stock object
                 // Highlight selected stock
                document.querySelectorAll('#my-stock-list .stock-item').forEach(el => el.classList.remove('selected'));
                item.classList.add('selected');
            };
            myStockList.appendChild(item);
        });
    } else {
        myStockList.innerHTML = '<div class="stock-item"><span>Du besitzt keine Aktien.</span></div>';
    }
}
