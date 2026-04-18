CREATE DATABASE IF NOT EXISTS energy_analyzer;
USE energy_analyzer;

-- Country Dimensions 
CREATE TABLE dim_country (
    country_id INT AUTO_INCREMENT PRIMARY KEY,
    country_name VARCHAR(100) NOT NULL UNIQUE,
    iso_code VARCHAR(10),
    region VARCHAR(100),
    continent VARCHAR(50)
);

-- Energy Reserves/Sources Dimensions
CREATE TABLE dim_energy_source (
   source_id INT AUTO_INCREMENT PRIMARY KEY,
   source_name VARCHAR(100) NOT NULL UNIQUE, -- coal, solar, or others
   is_renewable BOOLEAN NOT NULL DEFAULT FALSE, 
   source_type VARCHAR(50) -- if it is renewable or fossil fuels
);

-- Year dimension
CREATE TABLE dim_year (
	year SMALLINT PRIMARY KEY,
	decade SMALLINT, -- if that was 1990, 2000, 2010 so on....
	is_post_paris BOOLEAN  -- True if year >= 2016 (paris agreement)
);

-- Core Fact table - Energy consumption

CREATE TABLE fact_consumption (
	fact_id        BIGINT AUTO_INCREMENT PRIMARY KEY,
    country_id     INT NOT NULL,
    source_id      INT NOT NULL,
    year           SMALLINT NOT NULL,
    consumption_twh DECIMAL(12, 3),
    share_of_total  DECIMAL(6, 3),   -- % share of total energy mix
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (source_id) REFERENCES dim_energy_source(source_id),
    FOREIGN KEY (year) REFERENCES dim_year(year),
    -- ENSURES NO TWO ROWS HAS SAME COMBINATION OF VALUES (i.e, country, source, year) 
    UNIQUE KEY uq_fact (country_id, source_id, year)
);

-- Country metadata (economic indicators)

CREATE TABLE fact_country_meta (
    meta_id      BIGINT AUTO_INCREMENT PRIMARY KEY,
    country_id   INT NOT NULL,
    year         SMALLINT NOT NULL,
    population   BIGINT,
    gdp_usd      DECIMAL(18, 2),     -- nominal GDP in USD
    gdp_per_capita DECIMAL(12, 2),
    FOREIGN KEY (country_id) REFERENCES dim_country(country_id),
    FOREIGN KEY (year)       REFERENCES dim_year(year),
    UNIQUE KEY uq_meta (country_id, year)
);

-- Indexes for query performance

CREATE INDEX idx_fact_country ON fact_consumption(country_id);
CREATE INDEX idx_fact_year    ON fact_consumption(year);
CREATE INDEX idx_fact_source  ON fact_consumption(source_id);
CREATE INDEX idx_meta_country ON fact_country_meta(country_id);



-- ─────────────────────────────────────────
-- Seed: dim_country
-- ─────────────────────────────────────────
INSERT INTO dim_country (country_name, iso_code, region, continent) VALUES
('India',          'IND', 'South Asia',     'Asia'),
('China',          'CHN', 'East Asia',       'Asia'),
('Germany',        'DEU', 'Western Europe',  'Europe'),
('USA',            'USA', 'North America',   'North America'),
('Brazil',         'BRA', 'South America',   'South America'),
('France',         'FRA', 'Western Europe',  'Europe'),
('Japan',          'JPN', 'East Asia',       'Asia'),
('South Africa',   'ZAF', 'Sub-Saharan Africa', 'Africa'),
('Australia',      'AUS', 'Oceania',         'Oceania'),
('Saudi Arabia',   'SAU', 'Middle East',     'Asia');

-- ─────────────────────────────────────────
-- Seed: dim_energy_source
-- ─────────────────────────────────────────
INSERT INTO dim_energy_source (source_name, is_renewable, source_type) VALUES
('Coal',        FALSE, 'Fossil'),
('Oil',         FALSE, 'Fossil'),
('Natural Gas', FALSE, 'Fossil'),
('Solar',       TRUE,  'Renewable'),
('Wind',        TRUE,  'Renewable'),
('Hydro',       TRUE,  'Renewable'),
('Nuclear',     FALSE, 'Nuclear'),
('Biofuel',     TRUE,  'Renewable');

-- ─────────────────────────────────────────
-- Seed: dim_year
-- ─────────────────────────────────────────
INSERT INTO dim_year (year, decade, is_post_paris) VALUES
(2015, 2010, FALSE),
(2016, 2010, TRUE),
(2017, 2010, TRUE),
(2018, 2010, TRUE),
(2019, 2010, TRUE),
(2020, 2020, TRUE),
(2021, 2020, TRUE),
(2022, 2020, TRUE);

-- ─────────────────────────────────────────
-- Seed: fact_consumption (sample rows)
-- ─────────────────────────────────────────
INSERT INTO fact_consumption (country_id, source_id, year, consumption_twh, share_of_total) VALUES
-- India (id=1): Coal=1, Oil=2, Solar=4, Wind=5
(1, 1, 2019, 950.000,  55.2), (1, 1, 2020, 920.000, 54.1),
(1, 1, 2021, 980.000,  54.8), (1, 1, 2022, 1020.000, 55.0),
(1, 4, 2019,  35.000,   2.0), (1, 4, 2020,  50.000,  2.9),
(1, 4, 2021,  72.000,   4.0), (1, 4, 2022,  98.000,  5.3),
(1, 5, 2019,  55.000,   3.2), (1, 5, 2020,  60.000,  3.5),
(1, 5, 2021,  68.000,   3.8), (1, 5, 2022,  82.000,  4.4),

-- China (id=2): Coal=1, Solar=4, Wind=5
(2, 1, 2019, 3800.000, 57.7), (2, 1, 2020, 3600.000, 56.2),
(2, 1, 2021, 4100.000, 56.8), (2, 1, 2022, 4400.000, 56.4),
(2, 4, 2019,  224.000,  3.4), (2, 4, 2020,  261.000,  4.1),
(2, 4, 2021,  327.000,  4.5), (2, 4, 2022,  425.000,  5.4),
(2, 5, 2019,  406.000,  6.2), (2, 5, 2020,  467.000,  7.3),
(2, 5, 2021,  556.000,  7.7), (2, 5, 2022,  696.000,  8.9),

-- Germany (id=3): Coal=1, Solar=4, Wind=5, Nuclear=7
(3, 1, 2019,  220.000, 27.5), (3, 1, 2020,  182.000, 23.8),
(3, 1, 2021,  193.000, 24.6), (3, 1, 2022,  162.000, 21.4),
(3, 4, 2019,   47.000,  5.9), (3, 4, 2020,   51.000,  6.7),
(3, 4, 2021,   49.000,  6.2), (3, 4, 2022,   59.000,  7.8),
(3, 5, 2019,  126.000, 15.7), (3, 5, 2020,  131.000, 17.1),
(3, 5, 2021,  113.000, 14.4), (3, 5, 2022,  132.000, 17.4),
(3, 7, 2019,   75.000,  9.4), (3, 7, 2020,   61.000,  8.0),
(3, 7, 2021,   65.000,  8.3), (3, 7, 2022,   32.000,  4.2),

-- USA (id=4): Coal=1, Natural Gas=3, Solar=4, Wind=5
(4, 1, 2019,  965.000, 22.8), (4, 1, 2020,  774.000, 19.0),
(4, 1, 2021,  898.000, 21.5), (4, 1, 2022,  857.000, 19.8),
(4, 3, 2019, 1550.000, 36.6), (4, 3, 2020, 1489.000, 36.5),
(4, 3, 2021, 1576.000, 37.8), (4, 3, 2022, 1637.000, 37.9),
(4, 4, 2019,   99.000,  2.3), (4, 4, 2020,  131.000,  3.2),
(4, 4, 2021,  179.000,  4.3), (4, 4, 2022,  239.000,  5.5),
(4, 5, 2019,  300.000,  7.1), (4, 5, 2020,  338.000,  8.3),
(4, 5, 2021,  380.000,  9.1), (4, 5, 2022,  434.000, 10.0),

-- Brazil (id=5): Hydro=6, Oil=2, Biofuel=8
(5, 6, 2019,  396.000, 65.2), (5, 6, 2020,  390.000, 65.8),
(5, 6, 2021,  360.000, 60.1), (5, 6, 2022,  375.000, 61.0),
(5, 2, 2019,   98.000, 16.1), (5, 2, 2020,   93.000, 15.7),
(5, 2, 2021,  102.000, 17.0), (5, 2, 2022,  105.000, 17.1),
(5, 8, 2019,   62.000, 10.2), (5, 8, 2020,   59.000,  9.9),
(5, 8, 2021,   65.000, 10.9), (5, 8, 2022,   68.000, 11.1);

-- ─────────────────────────────────────────
-- Seed: fact_country_meta
-- ─────────────────────────────────────────
INSERT INTO fact_country_meta (country_id, year, population, gdp_usd, gdp_per_capita) VALUES
(1, 2019, 1366417754,  2835000000000.00,  2075.00),
(1, 2020, 1380004385,  2671000000000.00,  1936.00),
(1, 2021, 1393409038,  3176000000000.00,  2277.00),
(1, 2022, 1406631776,  3385000000000.00,  2408.00),
(2, 2019, 1400050000, 14279937500000.00, 10200.00),
(2, 2020, 1411100000, 14722730700000.00, 10435.00),
(2, 2021, 1412600000, 17734062640000.00, 12556.00),
(2, 2022, 1412600000, 17963170940000.00, 12720.00),
(3, 2019,   83132799,  3845630000000.00, 46259.00),
(3, 2020,   83240525,  3846410000000.00, 46208.00),
(3, 2021,   83200000,  4259935000000.00, 51203.00),
(3, 2022,   84270625,  4072191600000.00, 48718.00),
(4, 2019,  329064917, 21433226000000.00, 65120.00),
(4, 2020,  331501080, 20936600000000.00, 63179.00),
(4, 2021,  332915073, 23315081000000.00, 70030.00),
(4, 2022,  335942003, 25464478000000.00, 76399.00),
(5, 2019,  211049519,  1839757000000.00,  8717.00),
(5, 2020,  212559417,  1448600000000.00,  6797.00),
(5, 2021,  214326223,  1649620000000.00,  7507.00),
(5, 2022,  215313498,  1920096000000.00,  8919.00);


SELECT * FROM dim_country;
SELECT * FROM dim_energy_source;
SELECT * FROM dim_year;
SELECT * FROM fact_consumption;
SELECT * FROM fact_country_meta;

-- Q1. Total consumption per country in 2022, descending

SELECT 
    country_name, SUM(consumption_twh) AS total_twh_2022
FROM
    dim_country AS dc
        JOIN
    fact_consumption AS fc ON dc.country_id = fc.country_id
WHERE
    year = 2022
GROUP BY country_name
ORDER BY total_twh_2022 DESC;

-- Q2. All renewable energy consumption by country in 2022

SELECT 
    country_name,
    source_name,
    SUM(consumption_twh) AS total_twh_bySource
FROM
    dim_country AS dc
        JOIN
    fact_consumption AS fc ON dc.country_id = fc.country_id
        JOIN
    dim_energy_source AS des ON des.source_id = fc.source_id
WHERE
    (des.is_renewable = TRUE)
        AND (fc.year = 2022)
GROUP BY country_name , source_name
ORDER BY country_name , total_twh_bySource DESC;

-- Q3. Which energy source had the highest total global consumption across all years?

SELECT 
    source_name,
    source_type,
    SUM(consumption_twh) AS Highest_total_global_consumption
FROM
    fact_consumption AS fc
        JOIN
    dim_energy_source AS des ON fc.source_id = des.source_id
GROUP BY source_name , source_type
ORDER BY Highest_total_global_consumption DESC;

-- Q4. Renewable share (%) per country per year

SELECT 
    country_name,
    year,
    ROUND(SUM(CASE
                WHEN is_renewable = TRUE THEN consumption_twh
                ELSE 0
            END) / SUM(consumption_twh) * 100,
            2) AS Renewable_share_pct
FROM
    fact_consumption AS fc
        JOIN
    dim_country AS dc ON fc.country_id = dc.country_id
        JOIN
    dim_energy_source AS des ON fc.source_id = des.source_id
GROUP BY country_name , year
ORDER BY Renewable_share_pct DESC;

-- Q5. Year-over-Year (YoY) growth in total consumption per country

SELECT country_name, year, SUM(consumption_twh) AS total_twh,
LAG(SUM(consumption_twh)) OVER (PARTITION BY country_name ORDER BY year) AS prev_yr_twh,
ROUND(
(SUM(consumption_twh) - LAG(SUM(consumption_twh)) OVER (PARTITION BY country_name ORDER BY year)) /
LAG(SUM(consumption_twh)) OVER (PARTITION BY country_name ORDER BY year) * 100, 2
) AS YoY_pct
FROM dim_country AS dc
JOIN fact_consumption AS fc ON fc.country_id = dc.country_id
GROUP BY country_name, year
ORDER BY country_name; 

-- Q6. Rank countries by renewable consumption in each year

SELECT country_name, year,
SUM(consumption_twh) AS renewable_cons_twh,
RANK() OVER(PARTITION BY year ORDER BY SUM(consumption_twh)) AS renewable_consumption_rank
FROM dim_country AS dc
JOIN fact_consumption AS fc ON dc.country_id = fc.country_id
JOIN dim_energy_source AS des ON des.source_id = fc.source_id
WHERE is_renewable = TRUE
GROUP BY country_name, year
ORDER BY country_name;

-- Q7. Countries whose coal consumption DECREASED post-Paris Agreement

WITH coal_by_period AS (  
SELECT country_name, 
AVG(CASE WHEN is_post_paris = FALSE THEN consumption_twh END) AS avg_pre_paris,
AVG(CASE WHEN is_post_paris = TRUE THEN consumption_twh END) AS avg_post_paris
FROM fact_consumption AS fc
JOIN dim_country AS dc ON fc.country_id = dc.country_id
JOIN dim_energy_source AS des ON fc.source_id = des.source_id
JOIN dim_year AS dy ON fc.year = dy.year
WHERE source_name = 'Coal'
GROUP BY country_name
) SELECT country_name,
ROUND(avg_pre_paris, 2) AS avg_pre_paris_twh,
ROUND(avg_post_paris, 2) AS avg_post_paris_consumption,
ROUND(avg_post_paris - avg_pre_paris, 2) AS change_twh
FROM coal_by_period
WHERE avg_post_paris < avg_pre_paris
ORDER BY change_twh ASC;

-- Q8. Running cumulative solar consumption per country over years

SELECT country_name, 
SUM(CASE WHEN source_name = 'Solar' THEN consumption_twh END) 
OVER(PARTITION BY country_name ORDER BY year ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) 
AS solar_consumption_twh
FROM fact_consumption AS fc
JOIN dim_country AS dc ON fc.country_id = dc.country_id
JOIN dim_energy_source As des ON fc.source_id = des.source_id
WHERE source_name = 'Solar'
ORDER BY country_name, year;

-- Q9. Consumption per capita (TWh per million people) per country per year

SELECT 
    dc.country_name, fc.year, fcm.population,
    SUM(consumption_twh) AS total_twh,
    ROUND(SUM(consumption_twh / (population / 1000000)), 3) AS Twh_per_million_ppl
FROM
    fact_consumption AS fc
        JOIN
    dim_country AS dc ON fc.country_id = dc.country_id
        JOIN
    fact_country_meta AS fcm ON fc.country_id = fcm.country_id
        JOIN
    dim_energy_source AS des ON fc.source_id = des.source_id
GROUP BY dc.country_name, fc.year, fcm.population;

-- Q10. Top 3 fastest-growing renewable sources globally (2019 → 2022)
 
SELECT 
    des.source_name,
    SUM(CASE
        WHEN fc.year = 2019 THEN fc.consumption_twh
    END) AS twh_2019,
    SUM(CASE
        WHEN fc.year = 2022 THEN fc.consumption_twh
    END) AS twh_2022,
    ROUND((SUM(CASE
                WHEN fc.year = 2022 THEN fc.consumption_twh
            END) - SUM(CASE
                WHEN fc.year = 2019 THEN fc.consumption_twh
            END)) / (SUM(CASE
                WHEN fc.year = 2019 THEN fc.consumption_twh
            END)) * 100,
            2) AS growth_pct
FROM
    fact_consumption AS fc
        JOIN
    dim_energy_source AS des ON fc.source_id = des.source_id
WHERE
    is_renewable = TRUE
GROUP BY des.source_name
ORDER BY growth_pct DESC
LIMIT 3;


-- Q11. Countries where renewable share EXCEEDS fossil share in 2022 
SELECT 
    dc.country_name,
    ROUND(SUM(CASE
                WHEN des.is_renewable = TRUE THEN fc.consumption_twh
                ELSE 0
            END) / SUM(fc.consumption_twh) * 100,
            2) AS renewable_share_pct,
    ROUND(SUM(CASE
                WHEN des.source_type = 'Fossil' THEN fc.consumption_twh
            END) / SUM(fc.consumption_twh) * 100,
            2) AS fossil_share_pct
FROM
    fact_consumption AS fc
        JOIN
    dim_country AS dc ON fc.country_id = dc.country_id
        JOIN
    dim_energy_source AS des ON fc.source_id = des.source_id
WHERE
    fc.year = 2022
GROUP BY dc.country_name
HAVING renewable_share_pct > fossil_share_pct;

-- Q12. Rolling 3-year average consumption per country

WITH country_yearly_consumption AS (
SELECT dc.country_name, fc.year, 
SUM(fc.consumption_twh) AS total_twh
FROM fact_consumption AS fc
JOIN dim_country AS dc ON fc.country_id = dc.country_id
GROUP BY dc.country_name, fc.year
) 
SELECT country_name, year, 
total_twh, 
ROUND(AVG(total_twh) OVER(PARTITION BY country_name ORDER BY year ROWS BETWEEN 2 PRECEDING AND CURRENT ROW), 2) 
AS rolling_3yr_avg
FROM country_yearly_consumption 
ORDER BY country_name, year;


-- Q13. Stored procedure — get full energy profile for any country

DELIMITER $$
CREATE PROCEDURE GetCountryProfile(IN p_country VARCHAR(100), IN p_year SMALLINT)
BEGIN 
     SELECT dc.country_name, 
     des.source_name,
     des.source_type,
     des.is_renewable,
     fc.consumption_twh,
     fc.share_of_total
     FROM fact_consumption AS fc
     JOIN dim_country AS dc ON fc.country_id = dc.country_id
     JOIN dim_energy_source AS des ON fc.source_id = des.source_id
     WHERE dc.country_name = p_country AND fc.year = p_year
     ORDER BY fc.consumption_twh DESC;
END $$
DELIMITER ;

CALL GetCountryProfile('Germany', 2021);


-- Q14. View — renewable summary (reusable in Power BI)

CREATE VIEW vw_renewable_energy AS 
SELECT 
    dc.country_name,
    dc.continent,
    fc.year,
    fc.consumption_twh,
    des.source_name,
    des.source_type
FROM fact_consumption AS fc 
JOIN dim_country AS dc ON fc.country_id = dc.country_id
JOIN dim_energy_source AS des ON fc.source_id = des.source_id
WHERE des.is_renewable = TRUE
ORDER BY dc.country_name, fc.year ASC;

SELECT * FROM vw_renewable_energy;

-- Q15. CTE chain — countries with both high GDP and high renewable share
-- Tests: chaining multiple CTEs — shows strong SQL architecture thinking

WITH renewable_share AS (
     SELECT 
		   fc.country_id, 
           fc.year,
           ROUND(SUM(CASE WHEN des.is_renewable = TRUE THEN consumption_twh ELSE 0 END) / 
           SUM(consumption_twh) * 100, 2) as renewable_share_pct
     FROM fact_consumption AS fc
     JOIN dim_country AS dc ON fc.country_id = dc.country_id
     JOIN dim_energy_source AS des ON fc.source_id = des.source_id
     GROUP BY dc.country_name, fc.year
     ORDER BY fc.year DESC
), high_GDP AS (
    SELECT 
	      country_id, year
          gdp_per_capita
    FROM fact_country_meta
    WHERE gdp_per_capita > 20000
) SELECT dc.country_name, rs.year, 
         rs.renewable_share_pct, hg.gdp_per_capita
  FROM renewable_share AS rs
  JOIN high_GDP AS hg ON rs.country_id = hg.country_id
  JOIN dim_country AS dc ON rs.country_id = dc.country_id
  WHERE renewable_share_pct > 20
  ORDER BY rs.renewable_share_pct DESC;

