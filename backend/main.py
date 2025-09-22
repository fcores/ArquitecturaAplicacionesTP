from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, field_validator
from typing import List, Optional, Dict, Any
from enum import Enum
from datetime import datetime
import qrcode
import hashlib
import secrets
import json
import io
import base64
import os

# -----------------------------------------------------------------------------
# Configuración de la app (docs en /api/docs y openapi en /api/openapi.json)
# -----------------------------------------------------------------------------
app = FastAPI(
    title="TicketPardo API",
    description="API para el sistema de entradas del último partido de Messi",
    version="1.0.0",
    docs_url="/api/docs",
    openapi_url="/api/openapi.json",
    redoc_url=None,
)

# -----------------------------------------------------------------------------
# CORS
# -----------------------------------------------------------------------------
def get_cors_origins() -> List[str]:
    """
    Devuelve orígenes permitidos para CORS.
    - Usa CORS_ORIGINS si está definido (coma-separado o '*').
    - Incluye defaults para local y NodePort del front.
    """
    env_origins = os.getenv("CORS_ORIGINS", "")
    if env_origins.strip():
        if env_origins.strip() == "*":
            return ["*"]
        return list({o.strip() for o in env_origins.split(",") if o.strip()})

    # Defaults seguros para pruebas locales/minikube
    defaults = {
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    }

    # Si estás detrás de un NodePort (30080), podés sumar el IP del minikube/manual:
    # defaults.add(f"http://{minikube_ip}:30080")
    return list(defaults)

app.add_middleware(
    CORSMiddleware,
    allow_origins=get_cors_origins(),
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# -----------------------------------------------------------------------------
# Modelos
# -----------------------------------------------------------------------------
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

    @field_validator("quantity")
    @classmethod
    def validate_quantity(cls, v: int) -> int:
        if v < 1 or v > 10:
            raise ValueError("La cantidad debe estar entre 1 y 10")
        return v

    @field_validator("customer_name")
    @classmethod
    def validate_name(cls, v: str) -> str:
        if len(v.strip()) < 2:
            raise ValueError("El nombre debe tener al menos 2 caracteres")
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

# -----------------------------------------------------------------------------
# Datos simulados (in-memory)
# -----------------------------------------------------------------------------
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
        "description": "El adiós del GOAT del fútbol. No te pierdas este momento histórico.",
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
        "description": "Excelente vista panorámica del campo.",
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
        "description": "Vista completa del estadio.",
    },
]

categories_data = [
    {"id": 1, "name": "Platea Preferencial", "icon": "star", "description": "Vista privilegiada del campo"},
    {"id": 2, "name": "Platea Media", "icon": "eye", "description": "Excelente vista panorámica"},
    {"id": 3, "name": "Platea Alta", "icon": "mountain", "description": "Vista completa del estadio"},
    {"id": 4, "name": "Gradas Populares", "icon": "users", "description": "Ambiente de pasión futbolera"},
]

tickets_db: Dict[str, Dict[str, Any]] = {}
purchases_db: Dict[str, Dict[str, Any]] = {}

# -----------------------------------------------------------------------------
# Health
# -----------------------------------------------------------------------------
@app.get("/healthz")
async def root_healthz():
    return {"status": "ok", "time": datetime.utcnow().isoformat()}

@app.get("/api/healthz")
async def api_healthz():
    return {"status": "ok", "time": datetime.utcnow().isoformat()}

# -----------------------------------------------------------------------------
# Rutas API
# -----------------------------------------------------------------------------
@app.get("/")
async def root():
    return {"message": "TicketPardo API - Último Partido de Messi"}

@app.get("/api/cors-info")
async def cors_info():
    return {
        "cors_origins": get_cors_origins(),
        "total_origins": len(get_cors_origins()),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "cors_configured": True,
    }

@app.get("/api/events", response_model=List[Event])
async def get_events():
    return events_data

@app.get("/api/events/{event_id}", response_model=Event)
async def get_event(event_id: int):
    for e in events_data:
        if e["id"] == event_id:
            return e
    raise HTTPException(status_code=404, detail="Evento no encontrado")

@app.get("/api/categories")
async def get_categories():
    return categories_data

@app.post("/api/purchase", response_model=PurchaseResponse)
async def purchase_tickets(purchase: PurchaseRequest):
    # Buscar evento
    event = next((e for e in events_data if e["id"] == purchase.event_id), None)
    if not event:
        raise HTTPException(status_code=404, detail="Evento no encontrado")

    if event["status"] not in ["Disponible", "Agotándose"]:
        raise HTTPException(status_code=400, detail="Evento no disponible para compra")

    # IDs y totales
    ticket_id = f"TKT-{datetime.utcnow().strftime('%Y%m%d')}-{secrets.token_hex(4).upper()}"
    payment_reference = f"PAY-{secrets.token_hex(8).upper()}"
    purchase_date = datetime.utcnow()
    total_amount = purchase.quantity * event["price"]

    # Datos QR
    verification_hash = hashlib.sha256(
        f"{ticket_id}{purchase.customer_email}{purchase_date.isoformat()}".encode()
    ).hexdigest()[:16]

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
        "verification_hash": verification_hash,
    }

    # QR -> base64
    qr = qrcode.QRCode(
        version=1,
        error_correction=qrcode.constants.ERROR_CORRECT_H,
        box_size=12,
        border=4,
    )
    qr.add_data(json.dumps(qr_data, ensure_ascii=False))
    qr.make(fit=True)
    img = qr.make_image(fill_color="black", back_color="white")
    buf = io.BytesIO()
    img.save(buf, format="PNG", optimize=True)
    qr_base64 = base64.b64encode(buf.getvalue()).decode("utf-8")

    # Persistencia simulada
    record = {
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
        "used": False,
    }
    tickets_db[ticket_id] = record
    purchases_db[payment_reference] = record

    return PurchaseResponse(
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
            "category": event["category"],
        },
        payment_reference=payment_reference,
    )

@app.post("/api/newsletter")
async def subscribe_newsletter(subscription: NewsletterSubscription):
    return {
        "success": True,
        "message": f"Email {subscription.email} suscrito exitosamente al newsletter",
    }

@app.get("/api/search")
async def search_events(query: str):
    q = query.lower()
    results = [
        e for e in events_data
        if q in e["title"].lower() or q in e["location"].lower() or q in e["category"].lower()
    ]
    return results

@app.get("/api/ticket/{ticket_id}")
async def get_ticket(ticket_id: str):
    if ticket_id not in tickets_db:
        raise HTTPException(status_code=404, detail="Ticket no encontrado")
    t = tickets_db[ticket_id]
    return {
        "ticket_id": t["ticket_id"],
        "event_id": t["event_id"],
        "customer_name": t["customer_name"],
        "quantity": t["quantity"],
        "purchase_date": t["purchase_date"],
        "status": t["status"],
        "used": t["used"],
    }

@app.post("/api/verify-ticket")
async def verify_ticket(ticket_data: dict):
    ticket_id = ticket_data.get("ticket_id")
    verification_hash = ticket_data.get("verification_hash")

    if not ticket_id or not verification_hash:
        raise HTTPException(status_code=400, detail="Datos de verificación incompletos")

    if ticket_id not in tickets_db:
        return {"valid": False, "message": "Ticket no encontrado"}

    t = tickets_db[ticket_id]
    expected = hashlib.sha256(
        f"{ticket_id}{t['customer_email']}{t['purchase_date']}".encode()
    ).hexdigest()[:16]

    if verification_hash != expected:
        return {"valid": False, "message": "Ticket inválido o falsificado"}

    if t["used"]:
        return {"valid": False, "message": "Ticket ya utilizado"}

    return {
        "valid": True,
        "message": "Ticket válido",
        "ticket_info": {
            "event_title": t["qr_data"]["event_title"],
            "customer_name": t["customer_name"],
            "quantity": t["quantity"],
            "section": t["qr_data"]["section"],
        },
    }

@app.post("/api/use-ticket/{ticket_id}")
async def use_ticket(ticket_id: str):
    if ticket_id not in tickets_db:
        raise HTTPException(status_code=404, detail="Ticket no encontrado")

    if tickets_db[ticket_id]["used"]:
        raise HTTPException(status_code=400, detail="Ticket ya utilizado")

    tickets_db[ticket_id]["used"] = True
    tickets_db[ticket_id]["used_date"] = datetime.utcnow().isoformat()
    return {
        "success": True,
        "message": "Ticket marcado como usado",
        "used_date": tickets_db[ticket_id]["used_date"],
    }

# -----------------------------------------------------------------------------
# Dev server
# -----------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        app,
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info",
    )
