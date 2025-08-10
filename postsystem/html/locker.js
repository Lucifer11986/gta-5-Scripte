document.addEventListener("DOMContentLoaded", function () {
    const lockerContainer = document.getElementById("locker");
    const inventoryList = document.getElementById("locker-inventory");
    const closeButton = document.getElementById("closeLocker");

    window.addEventListener('message', function(event) {
        const data = event.data;
        if (data.action === 'openLocker') {
            populateLocker(data.inventory);
            lockerContainer.style.display = 'block';
        }
    });

    closeButton.addEventListener('click', function() {
        lockerContainer.style.display = 'none';
        fetch(`https://${GetParentResourceName()}/closeLocker`, { method: 'POST' });
    });

    inventoryList.addEventListener('click', function(e) {
        if (e.target && e.target.classList.contains('take-btn')) {
            const itemName = e.target.dataset.name;
            fetch(`https://${GetParentResourceName()}/takeFromMailbox`, {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify({ itemName: itemName })
            });
            // The UI will be updated by the 'postsystem:updateMailboxInventory' event from the client script
        }
    });

    function populateLocker(inventory) {
        inventoryList.innerHTML = '';
        if (inventory && inventory.length > 0) {
            inventory.forEach(item => {
                const li = document.createElement('li');
                li.className = 'locker-item';
                li.innerHTML = `
                    <span>${item.label || item.name} (x${item.count})</span>
                    <button class="take-btn" data-name="${item.name}">Nehmen</button>
                `;
                inventoryList.appendChild(li);
            });
        } else {
            inventoryList.innerHTML = '<li>Dein Briefkasten ist leer.</li>';
        }
    }
});
