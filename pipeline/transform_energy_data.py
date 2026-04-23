import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os
from urllib.parse import quote_plus

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__), '../.env'))

DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")


connection_string = f"mysql+pymysql://{DB_USER}:{quote_plus(DB_PASSWORD)}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_string)

print("\n Reading from owid_energy_raw table...\n")
with engine.connect() as conn:
    df_raw = pd.read_sql("SELECT * FROM owid_energy_raw", conn)

print(f"Raw table shape: {df_raw.shape}")
print(df_raw.head(10))

# Step 1: Populate dim_country
print("\nPopulating dim_country...")

countries = df_raw[['country']].drop_duplicates().reset_index(drop=True)

country_meta = {
    'India':          ('IND', 'South Asia',        'Asia'),
    'China':          ('CHN', 'East Asia',          'Asia'),
    'Germany':        ('DEU', 'Western Europe',     'Europe'),
    'United States':  ('USA', 'North America',      'North America'),
    'Brazil':         ('BRA', 'South America',      'South America'),
    'France':         ('FRA', 'Western Europe',     'Europe'),
    'Japan':          ('JPN', 'East Asia',          'Asia'),
    'South Africa':   ('ZAF', 'Sub-Saharan Africa', 'Africa'),
    'Australia':      ('AUS', 'Oceania',            'Oceania'),
    'Saudi Arabia':   ('SAU', 'Middle East',        'Asia'),
}

countries['iso_code'] = countries['country'].map(lambda x: country_meta[x][0])
countries['region'] = countries['country'].map(lambda x: country_meta[x][1])
countries['continent'] = countries['country'].map(lambda x: country_meta[x][2])

with engine.connect() as conn:
    for _, row in countries.iterrows():
        conn.execute(text("""
            INSERT INTO dim_country (country_name, iso_code, region, continent)
            VALUES (:name, :iso, :region, :continent)
            ON DUPLICATE KEY UPDATE iso_code = iso_code
        """), {"name": row['country'], "iso": row['iso_code'],
               "region": row['region'], "continent": row['continent']})
    conn.commit()

print(f"dim_country populated : {len(countries)} countries inserted.")


# Step 2: Populate dim_year
print("\n Populating dim_year...")

years = df_raw[['year']].drop_duplicates().reset_index(drop=True)
years['decade'] = (years['year'] // 10) * 10
years['is_post_paris'] = years['year'] >= 2016

with engine.connect() as conn:
    for _, row in years.iterrows():
        conn.execute(text("""
                          INSERT INTO dim_year (year, decade, is_post_paris) VALUES (:year, :decade, :is_post_paris)
                          ON DUPLICATE KEY UPDATE decade = decade 
                          """), {"year": int(row['year']), "decade": int(row['decade']), "is_post_paris": bool(row['is_post_paris'])})
        conn.commit()

print(f"dim_year populated : {len(years)} inserted.")

# Step 3: Populate fact_country_meta
print("\n Populating fact_country_meta...")

# Fetch country_id mapping from dim_country
with engine.connect() as conn:
    country_id_map = pd.read_sql(
        "SELECT country_id, country_name FROM dim_country", conn)

country_id_map = dict(
    zip(country_id_map['country_name'], country_id_map['country_id']))

meta_cols = df_raw[['country', 'year', 'population', 'gdp']].copy()
meta_cols['country_id'] = meta_cols['country'].map(country_id_map)
meta_cols['gdp_per_capita'] = meta_cols['gdp'] / meta_cols['population']

with engine.connect() as conn:
    for _, row in meta_cols.iterrows():
        conn.execute(text("""
            INSERT INTO fact_country_meta (country_id, year, population, gdp_usd, gdp_per_capita)
            VALUES 
            (:country_id, :year, :population, :gdp, :gdp_per_capita)
            ON DUPLICATE KEY UPDATE population = population 
        """), {"country_id": int(row['country_id']),
               "year": int(row['year']),
               "population": int(row['population']),
               "gdp": float(row['gdp']),
               "gdp_per_capita": float(row['gdp_per_capita'])})
    conn.commit()

print(f"fact_country_meta populated: {len(meta_cols)} rows inserted.")

# --- Step 4: Populate fact_consumption ---
print("\nPopulating fact_consumption...")

# Fetch source IDs from dim_energy_source
with engine.connect() as conn:
    source_id_map = pd.read_sql(
        "SELECT source_id, source_name FROM dim_energy_source", conn)

source_id_map = dict(
    zip(source_id_map['source_name'], source_id_map['source_id']))

# Map CSV column names to source names in dim_energy_source
source_column_map = {
    'coal_consumption':     'Coal',
    'oil_consumption':      'Oil',
    'gas_consumption':      'Natural Gas',
    'solar_consumption':    'Solar',
    'wind_consumption':     'Wind',
    'hydro_consumption':    'Hydro',
    'nuclear_consumption':  'Nuclear',
    'biofuel_consumption':  'Biofuel',
}

rows_inserted = 0

with engine.connect() as conn:
    for _, row in df_raw.iterrows():
        country_id = country_id_map.get(row['country'])

        for col, source_name in source_column_map.items():
            source_id = source_id_map.get(source_name)
            consumption = float(row[col])

            conn.execute(text("""
                INSERT INTO fact_consumption
                    (country_id, source_id, year, consumption_twh)
                VALUES
                    (:country_id, :source_id, :year, :consumption)
                ON DUPLICATE KEY UPDATE consumption_twh = consumption_twh
            """), {
                "country_id": int(country_id),
                "source_id": int(source_id),
                "year": int(row['year']),
                "consumption": consumption
            })
            rows_inserted += 1
    conn.commit()

print(f"fact_consumption populated : {rows_inserted} rows inserted.")
