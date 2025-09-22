from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, EmailStr, field_validator
from typing import List, Optional, Dict, Any
from datetime import datetime
from enum import Enum
import qrcode
import hashlib
import json
import base64
import secrets
import uuid
import io
import os

app = FastAPI(
    title="TicketPardo API",
    description="API para el sistema de entradas del último partido de Messi",
    version="1.0.0",
)

# ------------------------------------------------------------------------------
# CORS
# ------------------------------------------------------------------------------

def get_cors_origins() -> List[str]:
    """
    Orígenes permitidos:
      - por defecto: localhost/127.0.0.1 (dev)
      - si CORS_ORIGINS = "*" => todo permitido
      - si CORS_ORIGINS = "http://a,http://b" => usa esa lista
      - intenta agregar IP pública de EC2 (mejor esfuerzo)
    """
    env_origins = os.getenv("CORS_ORIGINS", "").strip()

    if env_origins == "*":
        return ["*"]

    origins: List[str] = [
        "http://localhost:3000",
        "http://127.0.0.1:3000",
    ]

    # Sumar orígenes pasados por env (separados por coma)
    if env_origins:
        origins.extend([o.strip() for o in env_origins.split(",") if o.strip()])

    # Mejor esfuerzo: IP pública de EC2 (no es requerido)
    try:
        import requests  # solo si está instalado
        ec2_ip = requests.get(
            "http://169.254.169.254/latest/meta-data/public-ipv4",
            timeout=2,
        ).text.strip()
        if ec2_ip:
            origins.extend([
                f"http://{ec2_ip}",
                f"http://{ec2_ip}:3000",
                f"http://{ec2_ip}:30080",
                f"http://{ec2_ip}:32000",
            ])
    except Exception:
        pass

    # Normalizar y quitar duplicados
    clean = []
    seen = set()
    for o in origins:
        if o and o not in seen:
            seen.add(o)
            clean.append(o)
    return clean


cors_origins = get_cors_origins()

app.add_middleware(
    CORSMiddleware,
    allow_origins=cors_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------------------------------------------------------------------
# Modelos
# ------------------------------------------------------------------------------

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


# ------------------------------------------------------------------------------
# Datos simulados
# ------------------------------------------------------------------------------

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

# “Bases de datos” simuladas en memoria
tickets_database: Dict[str, Dict[str, Any]] = {}
purchases_database: Dict[str, Dict[str, Any]] = {}

# ------------------------------------------------------------------------------
# Endpoints
# ------------------------------------------------------------------------------

@app.get("/")
async def root():
    return {"message": "TicketPardo API - Último Partido de Messi"}


@app.get("/healthz")
async def healthz():
    return {"status": "ok", "time": datetime.utcnow().isoformat()}


@app.get("/api/cors-info")
async def cors_info():
    return {
        "cors_origins": cors_origins,
        "total_origins": len(cors_origins),
        "environment": os.getenv("ENVIRONMENT", "development"),
        "cors_configured": True,
    }


@app.get("/api/events", response_model=List[Event])
async def get_events():
    return events_data


@app.get("/api/events/{event_id}", response_model=Event)
async def get_event(event_id: int):
    for event in events_data:
        if event["id"] == event_id:
            return event
    raise HTTPException(status_code=404, detail="Evento no encontrado")


@app.get("/api/categories")
async def get_categories():
    return categories_data


@app.post("/api/purchase", response_model=PurchaseResponse)
async def purchase_tickets(purchase: PurchaseRequest):
    try:
        # Buscar evento
        event = next((e for e in events_data if e["id"] == purchase.event_id), None)
        if not event:
            raise HTTPException(status_code=404, detail="Evento no encontrado")

        if event["status"] not in ["Disponible", "Agotándose"]:
            raise HTTPException(status_code=400, detail="Evento no disponible para compra")

        # IDs y fechas
        ticket_id = f"TKT-{datetime.now().strftime('%Y%m%d')}-{str(uuid.uuid4())[:8].upper()}"
        payment_reference = f"PAY-{secrets.token_hex(8).upper()}"
        purchase_date = datetime.now()

        # Monto total
        total_amount = purchase.quantity * event["price"]

        # Datos del QR
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
            "verification_hash": hashlib.sha256(
                f"{ticket_id}{purchase.customer_email}{purchase_date.isoformat()}".encode()
            ).hexdigest()[:16],
        }

        # Generar QR
        qr = qrcode.QRCode(
            version=1,
            error_correction=qrcode.constants.ERROR_CORRECT_H,
            box_size=12,
            border=4,
        )
        qr.add_data(json.dumps(qr_data, ensure_ascii=False))
        qr.make(fit=True)
        img = qr.make_image(fill_color="#1a1a1a", back_color="white")

        buf = io.BytesIO()
        img.save(buf, format="PNG", optimize=True)
        qr_base64 = base64.b64encode(buf.getvalue()).decode("utf-8")

        # Guardar “BD”
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
            "used": False,
        }
        tickets_database[ticket_id] = ticket_record
        purchases_database[payment_reference] = ticket_record

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
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error interno del servidor: {str(e)}")


@app.post("/api/newsletter")
async def subscribe_newsletter(subscription: NewsletterSubscription):
    return {
        "success": True,
        "message": f"Email {subscription.email} suscrito exitosamente al newsletter",
    }


@app.get("/api/search")
async def search_events(query: str):
    q = query.lower()
    results = []
    for event in events_data:
        if (
            q in event["title"].lower()
            or q in event["location"].lower()
            or q in event["category"].lower()
        ):
            results.append(event)
    return results


@app.get("/api/ticket/{ticket_id}")
async def get_ticket(ticket_id: str):
    if ticket_id not in tickets_database:
        raise HTTPException(status_code=404, detail="Ticket no encontrado")
    t = tickets_database[ticket_id]
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
async def verify_ticket(ticket_data: Dict[str, Any]):
    try:
        ticket_id = ticket_data.get("ticket_id")
        verification_hash = ticket_data.get("verification_hash")

        if not ticket_id or not verification_hash:
            raise HTTPException(status_code=400, detail="Datos de verificación incompletos")

        if ticket_id not in tickets_database:
            return {"valid": False, "message": "Ticket no encontrado"}

        t = tickets_database[ticket_id]
        expected_hash = hashlib.sha256(
            f"{ticket_id}{t['customer_email']}{t['purchase_date']}".encode()
        ).hexdigest()[:16]

        if verification_hash != expected_hash:
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
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error en verificación: {str(e)}")


@app.post("/api/use-ticket/{ticket_id}")
async def use_ticket(ticket_id: str):
    if ticket_id not in tickets_database:
        raise HTTPException(status_code=404, detail="Ticket no encontrado")

    t = tickets_database[ticket_id]
    if t["used"]:
        raise HTTPException(status_code=400, detail="Ticket ya utilizado")

    t["used"] = True
    t["used_date"] = datetime.now().isoformat()
    return {"success": True, "message": "Ticket marcado como usado", "used_date": t["used_date"]}


# ------------------------------------------------------------------------------
# Local dev runner (opcional)
# ------------------------------------------------------------------------------
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "backend.main:app",          # << IMPORTANTE para que funcione igual en local
        host="0.0.0.0",
        port=int(os.getenv("PORT", "8000")),
        reload=bool(os.getenv("DEV_RELOAD", "")),  # export DEV_RELOAD=1 si quieres hot-reload
        log_level="info",
    )
