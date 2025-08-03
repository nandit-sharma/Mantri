from pydantic_settings import BaseSettings
from dotenv import load_dotenv
import os

load_dotenv()

class Settings(BaseSettings):
    DATABASE_URL: str = "postgresql://mantri_user:mqU4UjjZjGTru9dSgijxZYicLudE2Psv@dpg-d27r4ru3jp1c73fli38g-a.oregon-postgres.render.com/mantri"
    SECRET_KEY: str = "ka4HpgwYemg-6krueqV1ydlWykAk18kT14Xmvy58YOo"
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30

settings = Settings() 