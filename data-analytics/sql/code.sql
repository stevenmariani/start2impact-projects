-- COUNTRIES WITH CONTINENTS
-- rinomina delle intestazioni di colonna

CREATE OR REPLACE TABLE `your_repository.Countries With Continents` AS
SELECT string_field_0 AS country,
       string_field_1 AS continent,
FROM `your_repository.Countries With Continents`;

-- GLOBAL COUNTRY INFORMATION DATASET
-- rimuovo i simboli $ e , dalla colonna gdp e casto come INT64 gdp

CREATE OR REPLACE TABLE `your_repository.Global Country Information Dataset` AS
SELECT *, 
       SAFE_CAST(REPLACE(REPLACE(gdp, '$', ''), ',', '') AS INT64) AS gdp_update
FROM `your_repository.Global Country Information Dataset`;

ALTER TABLE `your_repository.Global Country Information Dataset`
DROP COLUMN gdp;

-- GLOBAL DATA ON SUSTAINABLE ENERGY
-- rinomina delle intestazioni di colonna

CREATE OR REPLACE TABLE `your_repository.Global Data On Sustainable Energy` AS
SELECT Entity AS country,
       Year AS year,
       Access_to_electricity____of_population_ AS access_to_electricity,
       Access_to_clean_fuels_for_cooking AS access_to_clean_fuels_for_cooking,
       Renewable_electricity_generating_capacity_per_capita AS renewable_electricity_generating_capacity_per_capita,
       Financial_flows_to_developing_countries__US___ AS financial_flows_to_developing_countries_US,
       Electricity_from_fossil_fuels__TWh_ AS electricity_from_fossil_fuels_TWh,
       Electricity_from_nuclear__TWh_ AS electricity_from_nuclear_TWh,
       Electricity_from_renewables__TWh_ AS electricity_from_renewables_TWh,
       Low_carbon_electricity____electricity_ AS low_carbon_electricity,
       Primary_energy_consumption_per_capita__kWh_person_ AS primary_energy_consumption_per_capita_kWhp,
       Energy_intensity_level_of_primary_energy__MJ__2017_PPP_GDP_ AS energy_intensity_level_of_primary_energy,
       Value_co2_emissions_kt_by_country AS value_co2_emissions_kt_by_country,
       Renewables____equivalent_primary_energy_ AS renewables_equivalent_primary_energy,
       Density_n_P_Km2_ AS density_nP_Km2,
       Land_Area_Km2_ AS land_area_Km2_,
       Latitude AS latitude,
       Longitude AS longitude,
       gdp_growth AS gdp_growth,
       gdp_per_capita AS gdp_per_capita
FROM `your_repository.Global Data On Sustainable Energy`;

-- ANALISI 1
-- Quali sono i continenti con più popolazione?
SELECT continent, SUM(population) AS tot_population
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY continent
ORDER BY tot_population DESC;

-- ANALISI 2
-- Quali sono i continenti con più emissioni?
SELECT continent, SUM(co2_emissions) AS tot_co2_emissions
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY continent
ORDER BY tot_co2_emissions DESC;

-- ANALISI 2.1
-- Quali sono le country con più emissioni e a che continente appartengono?
SELECT global_country_info.country, country_continents.continent, SUM(co2_emissions) AS tot_co2_emissions
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY global_country_info.country, country_continents.continent
ORDER BY tot_co2_emissions DESC
LIMIT 10;

-- ANALISI 2.2
-- Quali sono le country con più emissioni, a che continente appartengono e in che percentuale sulle emissioni del continente emettono?
SELECT global_country_info.country, 
  country_continents.continent, 
  co2_emissions,
  ROUND((co2_emissions / SUM(co2_emissions) OVER (PARTITION BY country_continents.continent)) * 100, 2) AS percent_of_continent_emissions
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY global_country_info.country, country_continents.continent, co2_emissions
ORDER BY co2_emissions DESC, percent_of_continent_emissions DESC
LIMIT 10;

-- ANALISI 2.3
-- Quali sono le country con più emissioni, a che continente appartengono e in che percentuale sulle emissioni del continente emettono?
SELECT global_country_info.country, 
  country_continents.continent, 
  co2_emissions,
  ROUND((co2_emissions / SUM(co2_emissions) OVER (PARTITION BY country_continents.continent)) * 100, 2) AS percent_of_continent_emissions
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY global_country_info.country, country_continents.continent, co2_emissions
ORDER BY percent_of_continent_emissions DESC, co2_emissions DESC
LIMIT 10;

-- ANALISI 3
-- Quali sono i continenti con maggiori emissioni per capita?
SELECT continent, ROUND(SUM(co2_emissions)/SUM(population),4) AS co2_emissions_per_capita
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY continent
ORDER BY co2_emissions_per_capita DESC;

-- ANALISI 4
-- Quali sono i continenti con il maggior numero di forze armate?
SELECT continent, SUM(armed_forces_size) AS tot_armed_forces
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY continent
ORDER BY tot_armed_forces DESC;

-- ANALISI 4.1
-- Quali sono i continenti con il più alto rapporto tra forze armate e popolazione?
SELECT continent, ROUND(SUM(armed_forces_size)/SUM(population),4) AS armed_forces_per_capita
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY continent
ORDER BY armed_forces_per_capita DESC;

-- ANALISI 4.2
-- Quali sono le nazioni con il più alto rapporto tra forze armate e popolazione?
SELECT global_country_info.country, continent, ROUND(SUM(armed_forces_size)/SUM(population),4) AS armed_forces_per_capita, population
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
WHERE continent = "Europe"
GROUP BY global_country_info.country, continent, population
ORDER BY armed_forces_per_capita DESC
LIMIT 10;

-- ANALISI 4.3
-- Qual è il differenziale tra i vari record dell'ANALISI 4.2?
SELECT 
    global_country_info.country,
    continent, 
    ROUND(SUM(armed_forces_size)/SUM(population), 4) AS armed_forces_per_capita, 
    ROUND(
        ((SUM(armed_forces_size)/SUM(population)) - LAG(SUM(armed_forces_size)/SUM(population)) OVER (ORDER BY ROUND(SUM(armed_forces_size)/SUM(population), 4) DESC))
        / LAG(SUM(armed_forces_size)/SUM(population)) OVER (ORDER BY ROUND(SUM(armed_forces_size)/SUM(population), 4) DESC) 
        * 100, 
        2
    ) AS percent_change
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
WHERE continent = "Europe"
GROUP BY global_country_info.country, continent, population
ORDER BY armed_forces_per_capita DESC
LIMIT 10;

-- ANALISI 5
-- Qual è il continente con la % di terra agricola sul totale?
SELECT 
    continent,
    ROUND(SUM(land_areakm2*agricultural_land_percent)/SUM(land_areakm2),2) AS perc_agri_area,
    CONCAT(ROUND(SUM(land_areakm2*agricultural_land_percent/1000000),2),' milions of km2') AS tot_agri_area
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
GROUP BY continent
ORDER BY perc_agri_area DESC;

-- ANALISI 5.1
-- Qual è in Asia la top 10 delle nazioni con più terreno agricolo utilizzato?
SELECT 
    global_country_info.country,
    ROUND(SUM(land_areakm2*agricultural_land_percent)/SUM(land_areakm2),2) AS perc_agri_area,
    CONCAT(ROUND(SUM(land_areakm2*agricultural_land_percent/1000000),2),' milions of km2') AS tot_agri_area
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
WHERE continent = 'Asia'
GROUP BY country
ORDER BY perc_agri_area DESC
LIMIT 10;

-- ANALISI 5.1b
-- Qual è in Asia la top 10 delle nazioni con più terreno agricolo utilizzato?
SELECT 
    global_country_info.country,
    ROUND(SUM(land_areakm2*agricultural_land_percent)/SUM(land_areakm2),2) AS perc_agri_area,
    CONCAT(ROUND(SUM(land_areakm2*agricultural_land_percent/1000000),2),' milions of km2') AS tot_agri_area
FROM `your_repository.Global Country Information Dataset` AS global_country_info
LEFT JOIN `your_repository.Countries With Continents` AS country_continents
ON global_country_info.country = country_continents.country
WHERE continent = 'Asia'
GROUP BY country
ORDER BY tot_agri_area DESC
LIMIT 10;

-- ANALISI ENERGIA 1
-- Quali sono le top 10 nazioni per miglioramento nelle emissionoi di CO2 dal 2000 al 2019?
-- nb. sebbene il record per l'anno 2020 esista ha solo valori nulli per le emissioni CO2.
WITH emission_data AS (
 SELECT
   country,
   MAX(CASE WHEN year = 2000 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS co2_emission_2000,
   MAX(CASE WHEN year = 2019 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS co2_emission_2019
 FROM `your_repository.Global Data On Sustainable Energy`
 WHERE year IN (2000,2019)
 GROUP BY country
 ),
delta_data AS (
 SELECT
   country,
   co2_emission_2000,
   co2_emission_2019,
   ROUND((co2_emission_2019/co2_emission_2000 -1)*100,2) AS delta
 FROM emission_data
 WHERE co2_emission_2000 IS NOT NULL AND co2_emission_2019 IS NOT NULL
 )
SELECT
   country,
   co2_emission_2000,
   co2_emission_2019,
   delta
FROM
   delta_data
ORDER BY delta ASC
LIMIT 10;

-- ANALISI ENERGIA 1b
-- Quali sono le top 10 nazioni per miglioramento nelle emissionoi di CO2 dal 2000 al 2019?
-- Approfondisco limitando la SELECT alle nazioni che inquinavano in maniera importante sul totale
WITH emission_data AS (
  SELECT
    country,
    MAX(CASE WHEN year = 2000 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS co2_emission_2000,
    MAX(CASE WHEN year = 2019 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS co2_emission_2019
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year IN (2000,2019)
  GROUP BY country
  ),
average_data AS (
  SELECT
    AVG(value_co2_emissions_kt_by_country) AS average_co2_emission_2000
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year = 2000
  ),
delta_data AS (
  SELECT
    country,
    co2_emission_2000,
    co2_emission_2019,
    ROUND((co2_emission_2019/co2_emission_2000 -1)*100,2) AS delta
  FROM emission_data, average_data
  WHERE co2_emission_2000 IS NOT NULL AND co2_emission_2019 IS NOT NULL
  AND co2_emission_2000 > average_co2_emission_2000
  )
SELECT
    country,
    co2_emission_2000,
    co2_emission_2019,
    delta
FROM
    delta_data
ORDER BY delta ASC
LIMIT 10;

-- ANALISI ENERGIA 2
-- Quali sono le top 10 nazioni per adozione di energia rinnovabile?
WITH renewables_data AS (
 SELECT
   country,
   MAX(CASE WHEN year = 2000 THEN electricity_from_renewables_TWh ELSE NULL END) AS renewables_2000,
   MAX(CASE WHEN year = 2019 THEN electricity_from_renewables_TWh ELSE NULL END) AS renewables_2019
 FROM `your_repository.Global Data On Sustainable Energy`
 WHERE year IN (2000,2019) AND electricity_from_renewables_TWh > 0
 GROUP BY country
 ),
delta_data AS (
 SELECT
   country,
   renewables_2000,
   renewables_2019,
   ROUND((renewables_2019/renewables_2000 -1)*100,2) AS delta
 FROM renewables_data
 WHERE renewables_2000 IS NOT NULL AND renewables_2019 IS NOT NULL
 )
SELECT
   country,
   renewables_2000,
   renewables_2019,
   delta
FROM
   delta_data
ORDER BY delta DESC
LIMIT 10;

-- ANALISI ENERGIA 2b
-- Quali sono le top 10 nazioni per adozione di energia rinnovabile?
WITH renewables_data AS (
  SELECT
    country,
    MAX(CASE WHEN year = 2000 THEN electricity_from_renewables_TWh ELSE NULL END) AS renewables_2000,
    MAX(CASE WHEN year = 2019 THEN electricity_from_renewables_TWh ELSE NULL END) AS renewables_2019
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year IN (2000,2019) AND electricity_from_renewables_TWh > 0
  GROUP BY country
  ),
average_data AS (
  SELECT
    AVG(electricity_from_renewables_TWh) AS average_renewables_2000
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year = 2000
  ),
delta_data AS (
  SELECT
    country,
    renewables_2000,
    renewables_2019,
    ROUND((renewables_2019/renewables_2000 -1)*100,2) AS delta
  FROM renewables_data, average_data
  WHERE renewables_2000 IS NOT NULL AND renewables_2019 IS NOT NULL
  AND renewables_2000 > average_renewables_2000
  )
SELECT
    country,
    renewables_2000,
    renewables_2019,
    delta
FROM
    delta_data
ORDER BY delta DESC
LIMIT 10;

-- ANALISI ENERGIA 3
-- Quali sono le top 10 nazioni che hanno visto incrementare maggiormente i flussi finanziari?
WITH flows_data AS (
  SELECT
    country,
    MAX(CASE WHEN year = 2000 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2000,
    MAX(CASE WHEN year = 2019 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2019
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year IN (2000,2019) AND financial_flows_to_developing_countries_US > 0
  GROUP BY country
  ),
delta_data AS (
  SELECT
    country,
    flows_2000,
    flows_2019,
    ROUND((flows_2019/flows_2000 -1)*100,2) AS delta
  FROM flows_data
  WHERE flows_2000 IS NOT NULL AND flows_2019 IS NOT NULL
  )
SELECT
    country,
    flows_2000,
    flows_2019,
    delta
FROM
    delta_data
ORDER BY delta DESC
LIMIT 10;

-- ANALISI ENERGIA 3b
-- Quali sono le flop 10 nazioni che hanno visto incrementare maggiormente i flussi finanziari?
WITH flows_data AS (
  SELECT
    country,
    MAX(CASE WHEN year = 2000 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2000,
    MAX(CASE WHEN year = 2019 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2019
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year IN (2000,2019) AND financial_flows_to_developing_countries_US > 0
  GROUP BY country
  ),
delta_data AS (
  SELECT
    country,
    flows_2000,
    flows_2019,
    ROUND((flows_2019/flows_2000 -1)*100,2) AS delta
  FROM flows_data
  WHERE flows_2000 IS NOT NULL AND flows_2019 IS NOT NULL
  )
SELECT
    country,
    flows_2000,
    flows_2019,
    delta
FROM
    delta_data
ORDER BY delta ASC
LIMIT 10;

-- ANALISI 3c
-- In Malesia, Honduras e Jamaica com'è variato il rapporto tra flussi e la crescita del gdp per capita?
WITH flows_and_gdpcapita_data AS (
  SELECT
    country,
    MAX(CASE WHEN year = 2000 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2000,
    MAX(CASE WHEN year = 2019 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2019,
    MAX(CASE WHEN year = 2000 THEN gdp_per_capita ELSE NULL END) AS gdpcapita_2000,
    MAX(CASE WHEN year = 2019 THEN gdp_per_capita ELSE NULL END) AS gdpcapita_2019,
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year IN (2000,2019)
  GROUP BY country
  ),
delta_flows_gdpcapita_data AS (
  SELECT
    country,
    flows_2000,
    flows_2019,
    gdpcapita_2000,
    gdpcapita_2019,
    ROUND((flows_2019/flows_2000 -1)*100,2) AS delta_flows,
    ROUND((gdpcapita_2019/gdpcapita_2000 -1)*100,2) AS delta_gdpcapita,
  FROM flows_and_gdpcapita_data
  WHERE flows_2000 IS NOT NULL AND flows_2019 IS NOT NULL
  AND gdpcapita_2019 IS NOT NULL AND gdpcapita_2000 IS NOT NULL
  )
SELECT
    country,
    delta_flows,
    delta_gdpcapita,
FROM
    delta_flows_gdpcapita_data
ORDER BY delta_flows ASC
LIMIT 3;

-- ANALISI 3d
-- Quali sono state le top 3 nazioni per incremento di GDP per capita e che delta flussi hanno avuto?
WITH flows_and_gdpcapita_data AS (
  SELECT
    country,
    MAX(CASE WHEN year = 2000 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2000,
    MAX(CASE WHEN year = 2019 THEN financial_flows_to_developing_countries_US ELSE NULL END) AS flows_2019,
    MAX(CASE WHEN year = 2000 THEN gdp_per_capita ELSE NULL END) AS gdpcapita_2000,
    MAX(CASE WHEN year = 2019 THEN gdp_per_capita ELSE NULL END) AS gdpcapita_2019,
  FROM `your_repository.Global Data On Sustainable Energy`
  WHERE year IN (2000,2019)
  GROUP BY country
  ),
delta_flows_gdpcapita_data AS (
  SELECT
    country,
    flows_2000,
    flows_2019,
    gdpcapita_2000,
    gdpcapita_2019,
    ROUND((flows_2019/flows_2000 -1)*100,2) AS delta_flows,
    ROUND((gdpcapita_2019/gdpcapita_2000 -1)*100,2) AS delta_gdpcapita,
  FROM flows_and_gdpcapita_data
  WHERE flows_2000 IS NOT NULL AND flows_2019 IS NOT NULL
  AND gdpcapita_2019 IS NOT NULL AND gdpcapita_2000 IS NOT NULL
  )
SELECT
    country,
    delta_flows,
    delta_gdpcapita,
FROM
    delta_flows_gdpcapita_data
ORDER BY delta_gdpcapita DESC
LIMIT 3;

-- EXTRA analisi coefficienti
-- Quali sono le 10 nazioni dove il coefficiente tra energia rinnovabile e GDP per capita è maggiore?
SELECT
    country,
    ROUND(CORR(renewable_elect, gdp_per_capita), 2) AS corr_coeff
FROM (
    SELECT
        country,
        year,
        MAX(electricity_from_renewables_TWh) AS renewable_elect,
        MAX(gdp_per_capita) AS gdp_per_capita
    FROM
        `your_repository.Global Data On Sustainable Energy`
    WHERE gdp_per_capita IS NOT NULL
    GROUP BY
        country, year
    ORDER BY
        country, year
)
GROUP BY
    country
HAVING corr_coeff > 0
ORDER BY
    corr_coeff DESC
LIMIT 10;

-- EXTRA analisi coefficienti
-- Quali sono le 10 nazioni dove il coefficiente tra energia rinnovabile e GDP per capita è minore?
SELECT
    country,
    ROUND(CORR(renewable_elect, gdp_per_capita), 2) AS corr_coeff
FROM (
    SELECT
        country,
        year,
        MAX(electricity_from_renewables_TWh) AS renewable_elect,
        MAX(gdp_per_capita) AS gdp_per_capita
    FROM
        `your_repository.Global Data On Sustainable Energy`
    WHERE gdp_per_capita IS NOT NULL
    GROUP BY
        country, year
    ORDER BY
        country, year
)
GROUP BY
    country
HAVING corr_coeff > 0
ORDER BY
    corr_coeff ASC
LIMIT 10;

-- Analisi Italia
SELECT
    country,
    "access to electricity" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN access_to_electricity ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN access_to_electricity ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN access_to_electricity ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN access_to_electricity ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN access_to_electricity ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "electricity from fossil fuels TWh" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN electricity_from_fossil_fuels_TWh ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN electricity_from_fossil_fuels_TWh ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN electricity_from_fossil_fuels_TWh ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN electricity_from_fossil_fuels_TWh ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN electricity_from_fossil_fuels_TWh ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "electricity from nuclear TWh" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN electricity_from_nuclear_TWh ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN electricity_from_nuclear_TWh ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN electricity_from_nuclear_TWh ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN electricity_from_nuclear_TWh ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN electricity_from_nuclear_TWh ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "electricity from renewables TWh" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN electricity_from_renewables_TWh ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN electricity_from_renewables_TWh ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN electricity_from_renewables_TWh ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN electricity_from_renewables_TWh ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN electricity_from_renewables_TWh ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "value co2 emissions" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN value_co2_emissions_kt_by_country ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "gdp growth" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN gdp_growth ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN gdp_growth ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN gdp_growth ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN gdp_growth ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN gdp_growth ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "population density" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN density_nP_Km2 ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN density_nP_Km2 ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN density_nP_Km2 ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN density_nP_Km2 ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN density_nP_Km2 ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
UNION ALL
SELECT
    country,
    "gdp per capita" AS KPI,
    MAX(CASE WHEN Year = 2000 THEN gdp_per_capita ELSE NULL END) AS `2000`,
    MAX(CASE WHEN Year = 2005 THEN gdp_per_capita ELSE NULL END) AS `2005`,
    MAX(CASE WHEN Year = 2010 THEN gdp_per_capita ELSE NULL END) AS `2010`,
    MAX(CASE WHEN Year = 2015 THEN gdp_per_capita ELSE NULL END) AS `2015`,
    MAX(CASE WHEN Year = 2020 THEN gdp_per_capita ELSE NULL END) AS `2020`
FROM
    `your_repository.Global Data On Sustainable Energy`
WHERE
    country = "Italy"
GROUP BY
    country
