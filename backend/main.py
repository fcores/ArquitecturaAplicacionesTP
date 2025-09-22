from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, EmailStr, field_validator
from typing import List, Optional, Dict, Any
import qrcode
import io
import base64
from datetime import datetime, timedelta
import json
import uuid
import hashlib
import secrets
from enum import Enum

app = FastAPI(
    title="TicketPardo API",
    description="API para el sistema de entradas del último partido de Messi",
    version="1.0.0"
)

# Configuración CORS
import os
cors_origins = os.getenv("CORS_ORIGINS", "http://localhost:3000,http://127.0.0.1:3000").split(",")

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["*"],
)

# Modelos Pydantic
class Event(BaseModel):
    id: int
    title: str
    date: str
    location: str
    price: float
    category: str
    status: str
    image_url: str
    description: str

class Ticket(BaseModel):
    id: int
    event_id: int
    section: str
    row: str
    seat: str
    price: float
    status: str
    qr_code: Optional[str] = None

class PaymentMethod(str, Enum):
    CREDIT_CARD = "credit_card"
    DEBIT_CARD = "debit_card"
    BANK_TRANSFER = "bank_transfer"
    DIGITAL_WALLET = "digital_wallet"

class PurchaseRequest(BaseModel):
    event_id: int
    section: str
    quantity: int
    customer_email: EmailStr
    customer_name: str
    customer_phone: Optional[str] = None
    payment_method: PaymentMethod
    
    @field_validator('quantity')
    @classmethod
    def validate_quantity(cls, v):
        if v < 1 or v > 10:
            raise ValueError('La cantidad debe estar entre 1 y 10')
        return v
    
    @field_validator('customer_name')
    @classmethod
    def validate_name(cls, v):
        if len(v.strip()) < 2:
            raise ValueError('El nombre debe tener al menos 2 caracteres')
        return v.strip()

class PurchaseResponse(BaseModel):
    success: bool
    message: str
    ticket_id: str
    qr_code: str
    qr_data: Dict[str, Any]
    total_amount: float
    customer_email: str
    purchase_date: str
    event_details: Dict[str, Any]
    payment_reference: str

class NewsletterSubscription(BaseModel):
    email: str
    name: Optional[str] = None

# Base de datos simulada para tickets
tickets_database = {}
purchases_database = {}

# Datos simulados
events_data = [
    {
        "id": 1,
        "title": "Último Partido de Messi",
        "date": "15 de Diciembre, 2024",
        "location": "Estadio Monumental",
        "price": 250.0,
        "category": "Platea Preferencial",
        "status": "Agotándose",
        "image_url": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop",
        "description": "El adiós del GOAT del fútbol. No te pierdas este momento histórico."
    },
    {
        "id": 2,
        "title": "Último Partido de Messi",
        "date": "15 de Diciembre, 2024",
        "location": "Estadio Monumental",
        "price": 180.0,
        "category": "Platea Media",
        "status": "Disponible",
        "image_url": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop",
        "description": "Excelente vista panorámica del campo."
    },
    {
        "id": 3,
        "title": "Último Partido de Messi",
        "date": "15 de Diciembre, 2024",
        "location": "Estadio Monumental",
        "price": 120.0,
        "category": "Platea Alta",
        "status": "Próximamente",
        "image_url": "https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop",
        "description": "Vista completa del estadio."
    }
]

categories_data = [
    {"id": 1, "name": "Platea Preferencial", "icon": "star", "description": "Vista privilegiada del campo"},
    {"id": 2, "name": "Platea Media", "icon": "eye", "description": "Excelente vista panorámica"},
    {"id": 3, "name": "Platea Alta", "icon": "mountain", "description": "Vista completa del estadio"},
    {"id": 4, "name": "Gradas Populares", "icon": "users", "description": "Ambiente de pasión futbolera"}
]

# Endpoints
@app.get("/")
async def root():
    return {"message": "TicketPardo API - Último Partido de Messi"}

@app.get("/api/events", response_model=List[Event])
async def get_events():
    """Obtener todos los eventos disponibles"""
    return events_data

@app.get("/api/events/{event_id}", response_model=Event)
async def get_event(event_id: int):
    """Obtener un evento específico por ID"""
    for event in events_data:
        if event["id"] == event_id:
            return event
    raise HTTPException(status_code=404, detail="Evento no encontrado")

@app.get("/api/categories")
async def get_categories():
    """Obtener todas las categorías de entradas"""
    return categories_data

@app.post("/api/purchase", response_model=PurchaseResponse)
async def purchase_tickets(purchase: PurchaseRequest):
    """Procesar compra de entradas con validación mejorada y QR seguro"""
    try:
        # Buscar el evento
        event = None
        for e in events_data:
            if e["id"] == purchase.event_id:
                event = e
                break
        
        if not event:
            raise HTTPException(status_code=404, detail="Evento no encontrado")
        
        # Verificar disponibilidad
        if event["status"] not in ["Disponible", "Agotándose"]:
            raise HTTPException(status_code=400, detail="Evento no disponible para compra")
        
        # Generar IDs únicos
        ticket_id = f"TKT-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8].upper()}"
        payment_reference = f"PAY-{secrets.token_hex(8).upper()}"
        purchase_date = datetime.now()
        
        # Calcular precio total
        total_amount = purchase.quantity * event["price"]
        
        # Crear datos seguros para el QR
        qr_data = {
            "ticket_id": ticket_id,
            "event_id": purchase.event_id,
            "event_title": event["title"],
            "event_date": event["date"],
            "event_location": event["location"],
            "section": purchase.section,
            "quantity": purchase.quantity,
            "customer_name": purchase.customer_name,
            "customer_email": purchase.customer_email,
            "purchase_date": purchase_date.isoformat(),
            "total_amount": total_amount,
            "payment_reference": payment_reference,
            "verification_hash": hashlib.sha256(f"{ticket_id}{purchase.customer_email}{purchase_date.isoformat()}".encode()).hexdigest()[:16]
        }
        
        # Crear QR code con mejor configuración
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,  # Mayor corrección de errores
            box_size=12,
            border=4,
        )
        qr.add_data(json.dumps(qr_data, ensure_ascii=False))
        qr.make(fit=True)
        
        # Generar imagen del QR
        img = qr.make_image(fill_color="#1a1a1a", back_color="white")
        
        # Convertir a base64
        buffer = io.BytesIO()
        img.save(buffer, format='PNG', optimize=True)
        qr_base64 = base64.b64encode(buffer.getvalue()).decode('utf-8')
        
        # Guardar en base de datos simulada
        ticket_record = {
            "ticket_id": ticket_id,
            "event_id": purchase.event_id,
            "customer_name": purchase.customer_name,
            "customer_email": purchase.customer_email,
            "customer_phone": purchase.customer_phone,
            "quantity": purchase.quantity,
            "total_amount": total_amount,
            "payment_method": purchase.payment_method,
            "payment_reference": payment_reference,
            "purchase_date": purchase_date.isoformat(),
            "status": "confirmed",
            "qr_data": qr_data,
            "used": False
        }
        
        tickets_database[ticket_id] = ticket_record
        purchases_database[payment_reference] = ticket_record
        
        # Preparar respuesta
        response = PurchaseResponse(
            success=True,
            message="¡Compra procesada exitosamente! Tu entrada ha sido confirmada.",
            ticket_id=ticket_id,
            qr_code=f"data:image/png;base64,{qr_base64}",
            qr_data=qr_data,
            total_amount=total_amount,
            customer_email=purchase.customer_email,
            purchase_date=purchase_date.isoformat(),
            event_details={
                "title": event["title"],
                "date": event["date"],
                "location": event["location"],
                "category": event["category"]
            },
            payment_reference=payment_reference
        )
        
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {str(e)}")

@app.post("/api/newsletter")
async def subscribe_newsletter(subscription: NewsletterSubscription):
    """Suscribir a newsletter"""
    return {
        "success": True,
        "message": f"Email {subscription.email} suscrito exitosamente al newsletter"
    }

@app.get("/api/search")
async def search_events(query: str):
    """Buscar eventos por término"""
    query_lower = query.lower()
    results = []
    
    for event in events_data:
        if (query_lower in event["title"].lower() or 
            query_lower in event["location"].lower() or 
            query_lower in event["category"].lower()):
            results.append(event)
    
    return results

@app.get("/api/ticket/{ticket_id}")
async def get_ticket(ticket_id: str):
    """Obtener información de un ticket por ID"""
    if ticket_id not in tickets_database:
        raise HTTPException(status_code=404, detail="Ticket no encontrado")
    
    ticket = tickets_database[ticket_id]
    return {
        "ticket_id": ticket["ticket_id"],
        "event_id": ticket["event_id"],
        "customer_name": ticket["customer_name"],
        "quantity": ticket["quantity"],
        "purchase_date": ticket["purchase_date"],
        "status": ticket["status"],
        "used": ticket["used"]
    }

@app.post("/api/verify-ticket")
async def verify_ticket(ticket_data: dict):
    """Verificar la validez de un ticket usando el QR"""
    try:
        ticket_id = ticket_data.get("ticket_id")
        verification_hash = ticket_data.get("verification_hash")
        
        if not ticket_id or not verification_hash:
            raise HTTPException(status_code=400, detail="Datos de verificación incompletos")
        
        if ticket_id not in tickets_database:
            return {"valid": False, "message": "Ticket no encontrado"}
        
        ticket = tickets_database[ticket_id]
        expected_hash = hashlib.sha256(f"{ticket_id}{ticket['customer_email']}{ticket['purchase_date']}".encode()).hexdigest()[:16]
        
        if verification_hash != expected_hash:
            return {"valid": False, "message": "Ticket inválido o falsificado"}
        
        if ticket["used"]:
            return {"valid": False, "message": "Ticket ya utilizado"}
        
        return {
            "valid": True,
            "message": "Ticket válido",
            "ticket_info": {
                "event_title": ticket["qr_data"]["event_title"],
                "customer_name": ticket["customer_name"],
                "quantity": ticket["quantity"],
                "section": ticket["qr_data"]["section"]
            }
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en verificación: {str(e)}")

@app.post("/api/use-ticket/{ticket_id}")
async def use_ticket(ticket_id: str):
    """Marcar un ticket como usado"""
    if ticket_id not in tickets_database:
        raise HTTPException(status_code=404, detail="Ticket no encontrado")
    
    ticket = tickets_database[ticket_id]
    
    if ticket["used"]:
        raise HTTPException(status_code=400, detail="Ticket ya utilizado")
    
    tickets_database[ticket_id]["used"] = True
    tickets_database[ticket_id]["used_date"] = datetime.now().isoformat()
    
    return {
        "success": True,
        "message": "Ticket marcado como usado",
        "used_date": tickets_database[ticket_id]["used_date"]
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app, 
        host="0.0.0.0", 
        port=8000,
        reload=True,
        log_level="info"
    )
