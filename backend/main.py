from fastapi import FastAPI, HTTPException, Depends, status
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel
from typing import List, Optional
import qrcode
import io
import base64
from datetime import datetime
import json

app = FastAPI(
    title="TicketPardo API",
    description="API para el sistema de entradas del último partido de Messi",
    version="1.0.0"
)

# Configuración CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000", "http://127.0.0.1:3000", "http://3.20.238.113:3000"],
    allow_credentials=True,
    allow_methods=["*"],
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

class PurchaseRequest(BaseModel):
    event_id: int
    section: str
    quantity: int
    customer_email: str
    customer_name: str

class NewsletterSubscription(BaseModel):
    email: str
    name: Optional[str] = None

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

# Endpoints
@app.get("/health")
async def root():
    return "OK"

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

@app.post("/api/purchase")
async def purchase_tickets(purchase: PurchaseRequest):
    """Procesar compra de entradas"""
    # Simular procesamiento de compra
    if purchase.quantity <= 0:
        raise HTTPException(status_code=400, detail="Cantidad debe ser mayor a 0")
    
    # Generar QR code para la entrada
    qr_data = {
        "event_id": purchase.event_id,
        "section": purchase.section,
        "quantity": purchase.quantity,
        "customer": purchase.customer_email,
        "timestamp": datetime.now().isoformat()
    }
    
    # Crear QR code
    qr = qrcode.QRCode(version=1, box_size=10, border=5)
    qr.add_data(json.dumps(qr_data))
    qr.make(fit=True)
    
    img = qr.make_image(fill_color="black", back_color="white")
    
    # Convertir a base64
    buffer = io.BytesIO()
    img.save(buffer, format='PNG')
    qr_base64 = base64.b64encode(buffer.getvalue()).decode()
    
    return {
        "success": True,
        "message": "Compra procesada exitosamente",
        "ticket_id": f"TKT-{datetime.now().strftime('%Y%m%d%H%M%S')}",
        "qr_code": f"data:image/png;base64,{qr_base64}",
        "total_amount": purchase.quantity * 250.0,  # Precio fijo por simplicidad
        "customer_email": purchase.customer_email
    }

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

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
