document.addEventListener("DOMContentLoaded", function () {
    const uiContainer = document.getElementById("ui");
    const closeButton = document.getElementById("closeUI");
    const tabButtons = document.querySelectorAll(".tab-button");
    const tabContents = document.querySelectorAll(".tab-content");
    const policeTabButton = document.querySelector(".police-tab");
    const postmanActions = document.querySelector(".postman-actions");
    const startRouteButton = document.getElementById("startDeliveryRoute");
    const sendMailButton = document.getElementById("sendMail");
    const sendPackageButton = document.getElementById("sendPackage");
    const packageForm = document.getElementById("package-form");
    const noBoxWarning = document.getElementById("package-no-box-warning");
    const mailList = document.getElementById("mailList");
    const mailPreview = document.getElementById("mailPreview");
    const closePreviewButton = document.getElementById("closeMailPreview");
    const deleteMailButton = document.getElementById("deleteMail");
    const inspectionList = document.getElementById("inspectionList");

    // --- Event Listeners ---

    // Tabs
    tabButtons.forEach(button => {
        button.addEventListener("click", () => {
            tabButtons.forEach(btn => btn.classList.remove("active"));
            tabContents.forEach(content => content.classList.remove("active"));
            button.classList.add("active");
            document.getElementById(button.dataset.tab).classList.add("active");
        });
    });

    // Main Close Button
    closeButton.addEventListener("click", () => {
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
        uiContainer.style.display = "none";
    });

    // Postman: Start Route
    startRouteButton.addEventListener("click", () => {
        fetch(`https://${GetParentResourceName()}/startDeliveryRoute`, { method: "POST" });
        fetch(`https://${GetParentResourceName()}/closeUI`, { method: "POST" });
        uiContainer.style.display = "none";
    });

    // Send Mail
    sendMailButton.addEventListener("click", () => {
        const data = {
            station: document.getElementById("station").value,
            receiver: document.getElementById("receiver").value,
            message: document.getElementById("message").value,
            express: document.getElementById("express").checked
        };
        if (!data.station || !data.receiver || !data.message.trim()) return;
        fetch(`https://${GetParentResourceName()}/sendMail`, {
            method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data)
        });
        document.getElementById("message").value = "";
    });

    // Send Package
    sendPackageButton.addEventListener("click", () => {
        const data = {
            receiver: document.getElementById("package-receiver").value,
            itemName: document.getElementById("package-item").value,
            itemCount: parseInt(document.getElementById("package-item-count").value),
            express: document.getElementById("package-express").checked
        };
        if (!data.receiver || !data.itemName || !data.itemCount || data.itemCount <= 0) return;
        fetch(`https://${GetParentResourceName()}/sendPackage`, {
            method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify(data)
        });
    });

    // Confiscate Package
    inspectionList.addEventListener('click', function (e) {
        if (e.target && e.target.classList.contains('confiscate-btn')) {
            const packageId = e.target.dataset.id;
            fetch(`https://${GetParentResourceName()}/confiscatePackage`, {
                method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id: packageId })
            });
            e.target.parentElement.remove();
        }
    });

    // Mail Preview Buttons
    closePreviewButton.addEventListener("click", () => mailPreview.style.display = "none");
    deleteMailButton.addEventListener("click", function() {
        fetch(`https://${GetParentResourceName()}/deleteMail`, {
            method: "POST", headers: { "Content-Type": "application/json" }, body: JSON.stringify({ id: this.dataset.id })
        });
        mailPreview.style.display = "none";
    });

    // --- NUI Message Handler ---
    window.addEventListener("message", function (event) {
        if (event.data.action === "openUI") {
            populateUI(event.data);
            uiContainer.style.display = "block";
        }
    });

    // --- UI Population Functions ---
    function populateUI(data) {
        // Job-specific UI
        policeTabButton.style.display = data.isPolice ? "block" : "none";
        postmanActions.style.display = data.isPostman ? "block" : "none";
        if(data.isPolice) populateInspectionList(data.inspectionList);

        // Package form
        packageForm.style.display = data.hasBox ? "block" : "none";
        noBoxWarning.style.display = data.hasBox ? "none" : "block";

        // Dropdowns
        populateDropdown("station", data.stations, "name", "name");
        populateDropdown("receiver", data.players, "id", "name");
        populateDropdown("faction", data.factions, "name", "name");
        populateDropdown("package-receiver", data.players, "id", "name");
        populateDropdown("package-item", data.inventory, "name", "label");

        // Inbox
        mailList.innerHTML = "";
        if (data.receivedMessages) {
            data.receivedMessages.forEach(mail => {
                const li = document.createElement("li");
                li.innerHTML = `<strong>Von:</strong> ${mail.sender}<br><span>${mail.message.substring(0, 40)}...</span>`;
                li.addEventListener("click", () => {
                    document.getElementById("mailSender").textContent = mail.sender;
                    document.getElementById("mailMessage").textContent = mail.message;
                    deleteMailButton.dataset.id = mail.id;
                    mailPreview.style.display = "block";
                });
                mailList.appendChild(li);
            });
        }
    }

    function populateInspectionList(packages) {
        inspectionList.innerHTML = "";
        if (packages && packages.length > 0) {
            packages.forEach(pkg => {
                const li = document.createElement("li");
                li.className = 'inspection-item';
                li.innerHTML = `
                    <span>Paket #${pkg.id} | Absender: ${pkg.sender_name}</span>
                    <span>Inhalt: ${pkg.item_count}x ${pkg.item_name}</span>
                    <button class="confiscate-btn" data-id="${pkg.id}">Beschlagnahmen</button>
                `;
                inspectionList.appendChild(li);
            });
        } else {
            inspectionList.innerHTML = "<li>Keine Pakete zur Inspektion.</li>";
        }
    }

    function populateDropdown(id, items, valueKey, textKey) {
        const select = document.getElementById(id);
        if (!select) return;
        select.innerHTML = '<option value="">Bitte wählen...</option>';
        if (items && Array.isArray(items)) {
            items.forEach(item => {
                const option = document.createElement("option");
                option.value = item[valueKey];
                option.textContent = `${item[textKey]} ${item.count ? '(' + item.count + ')' : ''}`;
                select.appendChild(option);
            });
        }
    }
});
