from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    DEBUG: bool = True
    LOG_LEVEL: str = "INFO"

settings = Settings()