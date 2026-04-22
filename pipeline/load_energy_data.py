import pandas as pd
from sqlalchemy import create_engine, text
from dotenv import load_dotenv
import os
from urllib.parse import quote_plus

load_dotenv(dotenv_path=os.path.join(os.path.dirname(__file__),'../.env'))


# -- Configuration
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")



CSV_PATH = "../owid_energy_data.csv"

COUNTRIES = [
    'India', 'China', 'Germany', 'United States', 'Brazil',
    'France', 'Japan', 'South Africa', 'Australia', 'Saudi Arabia'
]

YEARS = list(range(2015, 2023))  # Since, we are using datas from 2015-2023

print("Reading CSV...\n")
df = pd.read_csv(CSV_PATH)
print("CSV Reading completed...\n")

# Filtering countries and Year
df_filtered = df[(df['country'].isin(COUNTRIES)) &
                 (df['year'].isin(YEARS))].copy()

print(f"Filtered Shape: {df_filtered.shape}")
print(df_filtered['country'].unique())

columns_required = columns_needed = [
    'country', 'year', 'population', 'gdp',
    'coal_consumption', 'oil_consumption', 'gas_consumption',
    'solar_consumption', 'wind_consumption', 'hydro_consumption',
    'nuclear_consumption', 'biofuel_consumption'
]

df_clean = df_filtered[columns_required].copy()

print("\n Cleaned Data Frame: \n")
print(df_clean.head(10))
print(f"\n NULL Values:\n{df_clean.isnull().sum()}")

print("\n Establishing Connection to MySQL...\n")

connection_string = f"mysql+pymysql://{DB_USER}:{quote_plus(DB_PASSWORD)}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(connection_string)

# Connection Test 
with engine.connect() as conn:
    result = conn.execute(text("SELECT DATABASE();"))
    print(f"Connection to: {result.fetchone()[0]}")


# Load data into MySQL ---
print("\nLoading data into MySQL...")

df_clean.to_sql(
    name="owid_energy_raw",
    con=engine,
    if_exists="replace",
    index=False
)

print(f"Data loaded successfully. {len(df_clean)} rows inserted into owid_energy_raw.")