document.addEventListener("DOMContentLoaded", function () {
    console.log("📦 Schließfach-UI geladen!");

    let lockerUI = document.getElementById("lockerUI");
    let closeButton = document.getElementById("closeLockerUI");
    let lockerItems = document.getElementById("lockerItems");

    if (!lockerUI || !closeButton || !lockerItems) {
        console.error("❌ Fehler: UI-Elemente nicht gefunden!");
        return;
    }

    // UI schließen
    closeButton.addEventListener("click", function () {
        lockerUI.style.display = "none";
        SetNuiFocus(false, false);
        fetch(`https://${GetParentResourceName()}/closeLockerUI`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({}),
        }).then(resp => resp.json()).then(resp => console.log(resp));
    });

    // Eventlistener für das Öffnen der Schließfach-UI
    window.addEventListener("message", function (event) {
        let data = event.data;
        if (data.action === "openLockerUI") {
            lockerUI.style.display = "block"; // Zeige die UI an
            SetNuiFocus(true, true); // Setze den Fokus auf die NUI

            // Fülle die Liste der Gegenstände im Schließfach
            lockerItems.innerHTML = "";

            if (data.items && Array.isArray(data.items)) {
                data.items.forEach(item => {
                    let li = document.createElement("li");
                    li.textContent = item.name;
                    lockerItems.appendChild(li);
                });
            }
        }
    });

    // Eventlistener für das Hinzufügen von Gegenständen ins Schließfach
    document.getElementById("addItemButton")?.addEventListener("click", function () {
        let itemName = document.getElementById("itemNameInput")?.value;
        if (!itemName || itemName.trim() === "") {
            console.error("❌ Fehler: Kein Gegenstandsname angegeben!");
            return;
        }

        // Sende den Gegenstand an den Server
        fetch(`https://${GetParentResourceName()}/addLockerItem`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({
                itemName: itemName
            }),
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                // Füge den Gegenstand zur Liste hinzu
                let li = document.createElement("li");
                li.textContent = itemName;
                lockerItems.appendChild(li);

                // Leere das Eingabefeld
                document.getElementById("itemNameInput").value = "";
            } else {
                console.error("❌ Fehler beim Hinzufügen des Gegenstands:", resp.error);
            }
        });
    });

    // Eventlistener für das Entfernen von Gegenständen aus dem Schließfach
    document.getElementById("removeItemButton")?.addEventListener("click", function () {
        let itemName = document.getElementById("itemNameInput")?.value;
        if (!itemName || itemName.trim() === "") {
            console.error("❌ Fehler: Kein Gegenstandsname angegeben!");
            return;
        }

        // Sende den Gegenstand an den Server
        fetch(`https://${GetParentResourceName()}/removeLockerItem`, {
            method: "POST",
            headers: {
                "Content-Type": "application/json; charset=UTF-8",
            },
            body: JSON.stringify({
                itemName: itemName
            }),
        }).then(resp => resp.json()).then(resp => {
            if (resp.success) {
                // Entferne den Gegenstand aus der Liste
                let items = lockerItems.getElementsByTagName("li");
                for (let i = 0; i < items.length; i++) {
                    if (items[i].textContent === itemName) {
                        lockerItems.removeChild(items[i]);
                        break;
                    }
                }

                // Leere das Eingabefeld
                document.getElementById("itemNameInput").value = "";
            } else {
                console.error("❌ Fehler beim Entfernen des Gegenstands:", resp.error);
            }
        });
    });
});