# Phase 2 — Python Pipeline Notes

## Core Tools
- **Pandas** : read, filter, and transform CSV data
- **SQLAlchemy** : connects Python to MySQL via a connection string
- **PyMySQL** : the driver SQLAlchemy uses to talk to MySQL under the hood
- **python-dotenv** : loads credentials from .env file into os.getenv()

## Connection String Format
```python
f"mysql+pymysql://user:password@host:port/database"
```
- If password has special characters like @, wrap with `quote_plus(password)`

## Key Patterns

### Read CSV
```python
df = pd.read_csv("file.csv")
```

### Filter DataFrame
```python
df_filtered = df[(df['country'].isin(COUNTRIES)) & (df['year'].isin(YEARS))].copy()
```

### Read from database into DataFrame
```python
df = pd.read_sql("SELECT * FROM table", conn)
```

### Load DataFrame into database
```python
df.to_sql(name="table_name", con=engine, if_exists="replace", index=False)
```
- `if_exists="replace"` — drops and recreates table
- `if_exists="append"` — adds rows to existing table

### Safe insert — skip duplicates silently
```sql
INSERT INTO table (col1, col2)
VALUES (:val1, :val2)
ON DUPLICATE KEY UPDATE col1 = col1
```
- Used when table has UNIQUE constraints
- If row exists → skip. If not → insert.

### Execute raw SQL in Python
```python
with engine.connect() as conn:
    conn.execute(text("YOUR SQL HERE"), {"param": value})
    conn.commit()
```
- Always call `conn.commit()` after inserts/updates

## Pipeline Architecture
owid_energy_data.csv
|
load_energy_data.py        → loads raw CSV into owid_energy_raw (staging)
|
transform_energy_data.py   → reads staging, populates star schema tables
|
dim_country, dim_year, fact_consumption, fact_country_meta

## Unpivoting concept
Wide table : one row per country per year, many source columns
Narrow table — one row per country per source per year

Use a column map to loop through source columns and insert one row at a time.

## .env file structure
```.env
DB_USER=root
DB_PASSWORD=yourpassword
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=energy_analyzer 
```
Always add .env to .gitignore -> never push credentials to GitHub.