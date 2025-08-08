Config = {}

-- ###############
-- # NEEDS SYSTEM
-- ###############

-- Set to true to use the built-in needs system where hunger/thirst/energy decrease over time.
-- Set to false if you want to use an external script (you will need to modify client.lua for this).
Config.UseInternalNeeds = true

-- Values decrease by this much every minute.
Config.HungerDecay = 0.5
Config.ThirstDecay = 0.8
Config.EnergyDecay = 0.2


-- ###############
-- # EXTERNAL SCRIPTS INTEGRATION
-- ###############
-- In this section, you can define which external scripts the HUD should get data from.
-- Just enter the name of the resource.

-- Name of your weather script resource. The HUD will try to call exports[resourceName]:GetTemperature().
Config.WeatherResourceName = 'weather_seassons'

-- Name of your drug/addiction script resource. The HUD will try to call exports[resourceName]:GetAddictionLevel().
Config.AddictionResourceName = 'drug_script'
