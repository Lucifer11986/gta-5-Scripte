Config = {}

-- ###############
-- # EXTERNAL SCRIPTS INTEGRATION
-- ###############
-- In this section, you can define which external scripts the HUD should get data from.
-- Just enter the name of the resource.

-- Name of your weather script resource. The HUD will try to call exports[resourceName]:GetTemperature().
Config.WeatherResourceName = 'weather_seassons'

-- Name of your drug/addiction script resource. The HUD will try to call exports[resourceName]:GetAddictionLevel().
Config.AddictionResourceName = 'drug_script'
