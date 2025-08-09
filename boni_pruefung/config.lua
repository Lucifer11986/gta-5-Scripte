Config = {}

Config.DailyBonus = 50 -- Täglicher Bonus für Premium-Rollen
Config.LoanWarningThreshold = 2 -- Anzahl der verpassten Zahlungen vor einer Warnung
Config.RepaymentInterval = 1440 -- Rückzahlungsintervall in Minuten (Standard: 24 Stunden)
Config.RepaymentAmount = 100 -- Standardmäßige Rückzahlung pro Intervall
Config.MaxLoanBase = 5000 -- Basis-Kreditlimit
Config.MaxLoanMultiplier = 10 -- Multiplikator für Kreditlimit basierend auf Bonität
Config.BaseInterestRate = 0.1 -- Basiszinssatz (10 %)
Config.CreditScorePenalty = 20 -- Abzug von Bonität bei neuer Kreditaufnahme
Config.CreditMultiplier = 100 -- Multipliziert die Bonität, um den maximal möglichen Kredit zu berechnen
Config.EarlyPaymentReward = 10 -- Bonuspunkte bei vollständiger frühzeitiger Zahlung
Config.OnTimePaymentReward = 5 -- Bonuspunkte bei rechtzeitiger Zahlung
Config.LatePaymentPenalty = -10 -- Punktabzug bei verspäteter Zahlung

-- Beruf für Banker
Config.BankerJob = "banker" -- Passe diesen Wert an den tatsächlichen Jobnamen in deiner Datenbank an

-- Premiumrollen für tägliche Bonitätsboni
Config.PremiumRoles = {
    ["vip"] = 10,
    ["elite"] = 20
}

-- Kreditlimits basierend auf Bonität
Config.CreditLimits = {
    [300] = 5000,   -- Bonität unter 300: Maximal 5000$
    [600] = 20000,  -- Bonität zwischen 300-599: Maximal 20000$
    [800] = 50000   -- Bonität ab 600: Maximal 50000$
}

-- Zinsen basierend auf Bonität
Config.InterestRates = {
    [300] = 10, -- Bonität unter 300: 10% Zinsen
    [600] = 5,  -- Bonität zwischen 300-599: 5% Zinsen
    [800] = 2   -- Bonität ab 600: 2% Zinsen
}

-- Strafzahlungen bei Kreditverspätungen
Config.MissedPaymentPenalty = 5 -- % Abzug von Bonität pro verpasster Zahlung

-- Versicherungskosten (monatlich)
Config.InsuranceCost = 100
