Config = {}

-- 📌 Liste der Drogen mit Suchtpotential
Config.Drugs = {
    ["cocaine"] = { addictionRate = 10, withdrawalChance = 5 }, 
    ["heroin"] = { addictionRate = 15, withdrawalChance = 10 }, 
    ["meth"] = { addictionRate = 12, withdrawalChance = 8 },
    ["weed"] = { addictionRate = 5, withdrawalChance = 2 },
    ["lsd"] = { addictionRate = 8, withdrawalChance = 4 },  -- Neue Droge: LSD
    ["ecstasy"] = { addictionRate = 7, withdrawalChance = 3 },  -- Neue Droge: Ecstasy
    ["crack"] = { addictionRate = 20, withdrawalChance = 15 }  -- Neue Droge: Crack
}

-- 📌 Maximales Suchtlevel (100 = schwerste Abhängigkeit)
Config.MaxAddictionLevel = 100

-- 📌 Entzugserscheinungen ab welchem Level?
Config.WithdrawalStartLevel = 50

-- 📌 Effekte von Entzugserscheinungen
Config.WithdrawalEffects = {
    blur = true, -- Verschwommenes Sehen
    movementSlow = true, -- Langsamere Bewegung
    shaking = true, -- Kamera-Wackeln
    healthLoss = true, -- Langsamer HP-Verlust
}

-- 📌 Möglichkeit, die Sucht zu heilen
Config.RehabCost = 5000 -- Preis für eine Therapie beim Arzt

-- 📌 Mindestzeit für eine Therapie (Minuten)
Config.RehabTime = 10

-- 📌 Medikamenten-Shop für Mediziner
Config.Shops = {
    { 
        job = 'medic', -- Nur Mediziner können diesen Shop nutzen
        items = {
            { name = 'medication', label = 'Therapie Medikament', price = 500, type = 'item' },
        }
    },
}

-- 📌 Effekt der Suchtheilung
Config.TherapyEffects = {
    cureAddiction = true,  -- Sucht wird geheilt
    withdrawalRelief = true,  -- Entzugserscheinungen werden gelindert
}

-- 📌 Droge-spezifische Effekte (z.B. LSD und Ecstasy)
Config.DrugEffects = {
    ["lsd"] = {
        hallucinations = true, -- Halluzinationen
        moodBoost = true, -- Verbesserte Stimmung
    },
    ["ecstasy"] = {
        euphoria = true, -- Euphorie
        enhancedPerception = true, -- Verbesserte Wahrnehmung
    },
    ["crack"] = {
        intenseRush = true, -- Intensiver Rausch
        paranoia = true, -- Paranoia
    }
}

-- 📌 Medikamente für Mediziner
Config.MedicItems = {
    ["medication"] = { label = 'Therapie Medikament', type = 'item', price = 500 },
}

-- 📌 Wichtige Konfigurationen
Config.RequiredMedicationForTherapy = 'medication'  -- Medikamentenname, das benötigt wird, um die Therapie durchzuführen
Config.TherapyDuration = 10  -- Dauer der Therapie in Sekunden
