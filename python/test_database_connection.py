import os

from dotenv import load_dotenv
from sqlalchemy import create_engine, text


# Load environment variables from .env
load_dotenv()


# Database configuration
DB_USER = os.getenv("DB_USER")
DB_PASSWORD = os.getenv("DB_PASSWORD")
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")


# Create PostgreSQL connection URL
DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{DB_USER}:{DB_PASSWORD}@"
    f"{DB_HOST}:{DB_PORT}/"
    f"{DB_NAME}"
)


# Create database engine
engine = create_engine(DATABASE_URL)


# Test connection
try:
    with engine.connect() as connection:

        result = connection.execute(
            text("SELECT version();")
        )

        version = result.fetchone()[0]

        print("Database connection successful!")
        print(f"PostgreSQL version: {version}")

except Exception as error:

    print("Database connection failed.")
    print(f"Error: {error}")