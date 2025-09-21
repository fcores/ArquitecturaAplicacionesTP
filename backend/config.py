"""
Configuración de la aplicación TicketPardo
"""

import os
from typing import List

class Settings:
    # Configuración de la aplicación
    APP_NAME: str = "TicketPardo API"
    APP_VERSION: str = "1.0.0"
    APP_DESCRIPTION: str = "API para el sistema de entradas del último partido de Messi"
    
    # Configuración del servidor
    HOST: str = os.getenv("HOST", "0.0.0.0")
    PORT: int = int(os.getenv("PORT", "8000"))
    DEBUG: bool = os.getenv("DEBUG", "True").lower() == "true"
    
    # Configuración CORS
    CORS_ORIGINS: List[str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
        "http://localhost:3001"
    ]
    
    # Configuración de base de datos (para futuras implementaciones)
    DATABASE_URL: str = os.getenv("DATABASE_URL", "sqlite:///./tickets.db")
    
    # Configuración de seguridad
    SECRET_KEY: str = os.getenv("SECRET_KEY", "your-secret-key-here")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    
    # Configuración de QR
    QR_ERROR_CORRECTION: str = "H"  # L, M, Q, H
    QR_BOX_SIZE: int = 12
    QR_BORDER: int = 4
    
    # Configuración de tickets
    MAX_TICKETS_PER_PURCHASE: int = 10
    MIN_TICKETS_PER_PURCHASE: int = 1

settings = Settings()
