document.addEventListener("DOMContentLoaded", function () {
    console.log("📢 UI vollständig geladen!");

    let uiContainer = document.getElementById("ui");
    let sendButton = document.getElementById("sendMail");
    let closeButton = document.getElementById("closeUI");
    let messageInput = document.getElementById("message");
    let charCount = document.getElementById("charCount");

    if (!uiContainer || !sendButton || !closeButton || !messageInput || !charCount) {
        console.error("❌ Fehler: UI-Elemente nicht gefunden!");
        return;
    }

    // Zeichenzähler aktualisieren
    messageInput.addEventListener("input", function () {
        let remainingChars = 160 - messageInput.value.length;
        charCount.textContent = `Zeichen übrig: ${remainingChars}`;

        // Optional: Warnung anzeigen, wenn die Zeichenanzahl überschritten wird
        if (remainingChars < 0) {
            charCount.style.color = "red";
        } else {
            charCount.style.color = "black";
        }
    });

    // Eventlistener für Nachrichten vom Server
    window.addEventListener("message", function (event) {
        let data = event.data;
        console.log("📩 UI-Daten erhalten:", data);

        if (data.action === "openUI") {
            showUI(data);
        } else if (data.action === "closeUI") {
            hideUI();
        } else if (data.action === "replyMail") {
            openUIWithReply(data.sender, data.message);
        }
    });

    // UI schließen
    closeButton.addEventListener("click", function () {
        fetch(`https://${GetParentResourceName()}/closeUI`, {
            method: "POST",
            headers: { "Content-Type": "application/json" },
            body: JSON.stringify({})
        }).then(() => {
            hideUI();
        }).catch(error => {
            console.error("❌ Fehler beim Schließen:", error);
            hideUI();
        });
    });

    // Mail senden
    sendButton.addEventListener("click", function () {
        let station = document.getElementById("station")?.value;
        let receiver = document.getElementById("receiver")?.value;
        let faction = document.getElementById("faction")?.value;
        let message = document.getElementById("message")?.value;
        let express = document.getElementById("express")?.checked;

        if (!station || !message.trim()) {
            console.error("❌ Fehler: Alle Felder müssen ausgefüllt sein!");
            return;
        }

        if (message.length > 160) {
            console.error("❌ Fehler: Die Nachricht darf maximal 160 Zeichen enthalten!");
            return;
        }

        if (faction) {
            // Sende eine Gruppen-Nachricht
            fetch(`https://${GetParentResourceName()}/sendGroupMail`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    station: station,
                    faction: faction,
                    message: message,
                    express: express
                })
            }).then(response => response.json())
              .then(data => {
                  console.log("📨 Gruppen-Nachricht gesendet:", data);
                  // Textfeld nach dem Senden leeren
                  document.getElementById("message").value = "";
                  charCount.textContent = "Zeichen übrig: 160";
              })
              .catch(error => console.error("❌ Fehler beim Senden:", error));
        } else if (receiver) {
            // Sende eine normale Nachricht
            fetch(`https://${GetParentResourceName()}/sendMail`, {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({
                    station: station,
                    receiver: receiver,
                    message: message,
                    express: express
                })
            }).then(response => response.json())
              .then(data => {
                  console.log("📨 Mail gesendet:", data);
                  // Textfeld nach dem Senden leeren
                  document.getElementById("message").value = "";
                  charCount.textContent = "Zeichen übrig: 160";
              })
              .catch(error => console.error("❌ Fehler beim Senden:", error));
        } else {
            console.error("❌ Fehler: Kein Empfänger oder Gruppe ausgewählt!");
        }
    });

    // UI anzeigen
    function showUI(data) {
        if (!uiContainer) return;
        uiContainer.style.display = "block";

        console.log("Empfangene Daten:", data); // Debugging: Zeige die empfangenen Daten an

        populateDropdown("station", data.stations);
        populateDropdown("receiver", data.players, "id", "name");
        populateDropdown("faction", data.factions);
        populateMailList(data.receivedMessages);
    }

    // UI ausblenden
    function hideUI() {
        if (!uiContainer) return;
        uiContainer.style.display = "none";
    }

    // Dropdowns befüllen
    function populateDropdown(id, items = [], valueKey = "name", textKey = "name") {
        let select = document.getElementById(id);
        if (!select) return console.error(`❌ Fehler: Dropdown '${id}' nicht gefunden!`);

        select.innerHTML = '<option value="">Bitte wählen...</option>';
        if (!Array.isArray(items)) {
            console.error(`❌ Fehler: Ungültige Daten für '${id}'`, items);
            return;
        }

        items.forEach(item => {
            let option = document.createElement("option");
            option.value = item[valueKey];
            option.textContent = item[textKey];
            select.appendChild(option);
        });
    }

    // Mail-Liste befüllen
    function populateMailList(mail = []) {
        let list = document.getElementById("mailList");
        if (!list) return console.error("❌ Fehler: `mailList` nicht gefunden!");

        list.innerHTML = "";

        if (!Array.isArray(mail)) {
            console.error("❌ Fehler: Ungültige Mail-Daten!", mail);
            return;
        }

        mail.forEach(item => {
            let mailItem = document.createElement("li");
            mailItem.className = "mail-item";
            mailItem.setAttribute("data-id", item.id); // Setze die Mail-ID als Datenattribut
            mailItem.innerHTML = `<strong>Von:</strong> ${item.sender} <br>
                                  <strong>Nachricht:</strong> ${item.message}
                                  <button class="delete-mail-btn" data-id="${item.id}">Löschen</button>`;
            list.appendChild(mailItem);

            // Eventlistener für das Öffnen der Mail-Vorschau
            mailItem.addEventListener("click", function () {
                document.getElementById("mailSender").textContent = item.sender;
                document.getElementById("mailMessage").textContent = item.message;
                document.getElementById("deleteMail").setAttribute("data-id", item.id); // Setze die Mail-ID für den Löschen-Button
                document.getElementById("mailPreview").style.display = "block";
            });
        });

        // Eventlistener für Löschen-Buttons
        document.querySelectorAll(".delete-mail-btn").forEach(button => {
            button.addEventListener("click", function (event) {
                event.stopPropagation(); // Verhindere, dass das Klicken auf den Löschen-Button die Mail-Vorschau öffnet
                let mailId = this.getAttribute("data-id");
                fetch(`https://${GetParentResourceName()}/deleteMail`, {
                    method: "POST",
                    headers: { "Content-Type": "application/json" },
                    body: JSON.stringify({ id: mailId })
                }).then(response => response.json())
                  .then(data => {
                      if (data.success) {
                          // Entferne die Mail aus der Liste
                          let mailItem = document.querySelector(`.mail-item[data-id="${mailId}"]`);
                          if (mailItem) {
                              mailItem.remove();
                          }
                          // Schließe die Mail-Vorschau
                          document.getElementById("mailPreview").style.display = "none";
                      } else {
                          console.error("❌ Fehler beim Löschen:", data.error);
                      }
                  })
                  .catch(error => console.error("❌ Fehler beim Löschen:", error));
            });
        });
    }

    // Öffne die UI mit vorausgefüllten Daten für eine Antwort
    function openUIWithReply(sender, message) {
        let receiverDropdown = document.getElementById("receiver");
        let messageInput = document.getElementById("message");

        // Setze den Empfänger
        if (receiverDropdown) {
            receiverDropdown.value = sender;
        }

        // Setze die Nachricht
        if (messageInput) {
            messageInput.value = "RE: " + message;
        }

        // Zeige die UI an
        document.getElementById("ui").style.display = "block";
        SetNuiFocus(true, true);
    }
});