#!/usr/bin/env python3
"""
Script de prueba para verificar la funcionalidad de la API de TicketPardo
"""

import requests
import json
import sys

API_BASE = "http://localhost:8000"

def test_api_health():
    """Verificar que la API esté funcionando"""
    try:
        response = requests.get(f"{API_BASE}/")
        if response.status_code == 200:
            print("✅ API está funcionando correctamente")
            print(f"   Respuesta: {response.json()}")
            return True
        else:
            print(f"❌ API no responde correctamente (status: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ Error conectando con la API: {e}")
        return False

def test_get_events():
    """Probar obtener eventos"""
    try:
        response = requests.get(f"{API_BASE}/api/events")
        if response.status_code == 200:
            events = response.json()
            print(f"✅ Eventos obtenidos correctamente ({len(events)} eventos)")
            for event in events:
                print(f"   - {event['title']} - {event['category']} - ${event['price']}")
            return True
        else:
            print(f"❌ Error obteniendo eventos (status: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ Error obteniendo eventos: {e}")
        return False

def test_get_categories():
    """Probar obtener categorías"""
    try:
        response = requests.get(f"{API_BASE}/api/categories")
        if response.status_code == 200:
            categories = response.json()
            print(f"✅ Categorías obtenidas correctamente ({len(categories)} categorías)")
            for cat in categories:
                print(f"   - {cat['name']}: {cat['description']}")
            return True
        else:
            print(f"❌ Error obteniendo categorías (status: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ Error obteniendo categorías: {e}")
        return False

def test_purchase_ticket():
    """Probar compra de entrada"""
    purchase_data = {
        "event_id": 1,
        "section": "Platea Preferencial",
        "quantity": 2,
        "customer_email": "test@example.com",
        "customer_name": "Juan Pérez",
        "customer_phone": "+54 9 11 1234-5678",
        "payment_method": "credit_card"
    }
    
    try:
        response = requests.post(f"{API_BASE}/api/purchase", json=purchase_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('success'):
                print("✅ Compra procesada exitosamente")
                print(f"   Ticket ID: {result['ticket_id']}")
                print(f"   Referencia de pago: {result['payment_reference']}")
                print(f"   Total: ${result['total_amount']}")
                print(f"   QR generado: {'Sí' if result.get('qr_code') else 'No'}")
                return result['ticket_id']
            else:
                print(f"❌ Compra falló: {result.get('message', 'Error desconocido')}")
                return None
        else:
            print(f"❌ Error en compra (status: {response.status_code})")
            print(f"   Respuesta: {response.text}")
            return None
    except Exception as e:
        print(f"❌ Error procesando compra: {e}")
        return None

def test_verify_ticket(ticket_id):
    """Probar verificación de ticket"""
    # Simular datos del QR (normalmente vendrían del QR escaneado)
    verification_data = {
        "ticket_id": ticket_id,
        "verification_hash": "test_hash"  # Este sería el hash real del QR
    }
    
    try:
        response = requests.post(f"{API_BASE}/api/verify-ticket", json=verification_data)
        if response.status_code == 200:
            result = response.json()
            if result.get('valid'):
                print("✅ Ticket verificado correctamente")
                print(f"   Mensaje: {result['message']}")
            else:
                print(f"⚠️  Ticket no válido: {result['message']}")
            return True
        else:
            print(f"❌ Error verificando ticket (status: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ Error verificando ticket: {e}")
        return False

def test_get_ticket(ticket_id):
    """Probar obtener información del ticket"""
    try:
        response = requests.get(f"{API_BASE}/api/ticket/{ticket_id}")
        if response.status_code == 200:
            ticket = response.json()
            print("✅ Información del ticket obtenida")
            print(f"   ID: {ticket['ticket_id']}")
            print(f"   Cliente: {ticket['customer_name']}")
            print(f"   Cantidad: {ticket['quantity']}")
            print(f"   Estado: {ticket['status']}")
            print(f"   Usado: {'Sí' if ticket['used'] else 'No'}")
            return True
        else:
            print(f"❌ Error obteniendo ticket (status: {response.status_code})")
            return False
    except Exception as e:
        print(f"❌ Error obteniendo ticket: {e}")
        return False

def main():
    """Ejecutar todas las pruebas"""
    print("🧪 Iniciando pruebas de la API de TicketPardo")
    print("=" * 50)
    
    tests_passed = 0
    total_tests = 0
    
    # Test 1: Health check
    total_tests += 1
    if test_api_health():
        tests_passed += 1
    print()
    
    # Test 2: Obtener eventos
    total_tests += 1
    if test_get_events():
        tests_passed += 1
    print()
    
    # Test 3: Obtener categorías
    total_tests += 1
    if test_get_categories():
        tests_passed += 1
    print()
    
    # Test 4: Comprar ticket
    total_tests += 1
    ticket_id = test_purchase_ticket()
    if ticket_id:
        tests_passed += 1
    print()
    
    # Test 5: Obtener información del ticket (solo si se creó uno)
    if ticket_id:
        total_tests += 1
        if test_get_ticket(ticket_id):
            tests_passed += 1
        print()
        
        # Test 6: Verificar ticket (solo si se creó uno)
        total_tests += 1
        if test_verify_ticket(ticket_id):
            tests_passed += 1
        print()
    
    # Resumen
    print("=" * 50)
    print(f"📊 Resumen de pruebas:")
    print(f"   Pruebas pasadas: {tests_passed}/{total_tests}")
    print(f"   Éxito: {(tests_passed/total_tests)*100:.1f}%")
    
    if tests_passed == total_tests:
        print("🎉 ¡Todas las pruebas pasaron correctamente!")
        return 0
    else:
        print("⚠️  Algunas pruebas fallaron")
        return 1

if __name__ == "__main__":
    sys.exit(main())
