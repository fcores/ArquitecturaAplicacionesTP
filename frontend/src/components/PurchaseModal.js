import React, { useState } from 'react';
import styled from 'styled-components';
import { motion, AnimatePresence } from 'framer-motion';
import { FaTimes, FaCalendar, FaMapMarkerAlt, FaTicketAlt, FaQrcode } from 'react-icons/fa';
import { QRCodeSVG } from 'qrcode.react';
import { useAppContext } from '../context/AppContext';

const ModalOverlay = styled(motion.div)`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.7);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 2000;
  padding: 1rem;
`;

const ModalContent = styled(motion.div)`
  background: var(--bg-primary);
  border-radius: var(--border-radius);
  max-width: 500px;
  width: 100%;
  max-height: 90vh;
  overflow-y: auto;
  position: relative;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
`;

const ModalHeader = styled.div`
  padding: 1.5rem;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  justify-content: space-between;
  
  h2 {
    color: var(--text-primary);
    font-size: 1.5rem;
    font-weight: 600;
  }
`;

const CloseButton = styled.button`
  background: none;
  border: none;
  font-size: 1.5rem;
  color: var(--text-secondary);
  cursor: pointer;
  padding: 0.5rem;
  border-radius: 50%;
  transition: var(--transition);
  
  &:hover {
    background: var(--bg-secondary);
    color: var(--text-primary);
  }
`;

const ModalBody = styled.div`
  padding: 1.5rem;
`;

const EventInfo = styled.div`
  display: flex;
  gap: 1rem;
  margin-bottom: 2rem;
  padding: 1rem;
  background: var(--bg-secondary);
  border-radius: var(--border-radius);
  
  @media (min-width: 768px) {
    padding: 1.5rem;
  }
`;

const EventImage = styled.img`
  width: 80px;
  height: 60px;
  border-radius: 8px;
  object-fit: cover;
  
  @media (min-width: 768px) {
    width: 100px;
    height: 75px;
  }
`;

const EventDetails = styled.div`
  flex: 1;
  
  h3 {
    font-size: 1.1rem;
    font-weight: 600;
    color: var(--text-primary);
    margin-bottom: 0.5rem;
    
    @media (min-width: 768px) {
      font-size: 1.25rem;
    }
  }
  
  .event-info {
    display: flex;
    flex-direction: column;
    gap: 0.5rem;
    font-size: 0.9rem;
    color: var(--text-secondary);
    
    .info-item {
      display: flex;
      align-items: center;
      gap: 0.5rem;
      
      svg {
        color: var(--primary);
      }
    }
  }
`;

const Form = styled.form`
  display: flex;
  flex-direction: column;
  gap: 1.5rem;
`;

const FormGroup = styled.div`
  .form-label {
    display: block;
    margin-bottom: 0.5rem;
    font-weight: 500;
    color: var(--text-primary);
  }
  
  .form-input {
    width: 100%;
    padding: 0.75rem 1rem;
    border: 2px solid var(--border);
    border-radius: var(--border-radius);
    font-size: 1rem;
    transition: var(--transition);
    
    &:focus {
      outline: none;
      border-color: var(--primary);
      box-shadow: 0 0 0 3px rgba(37, 99, 235, 0.1);
    }
  }
  
  .quantity-controls {
    display: flex;
    align-items: center;
    gap: 1rem;
    
    .quantity-btn {
      width: 40px;
      height: 40px;
      border: 2px solid var(--border);
      background: var(--bg-primary);
      border-radius: var(--border-radius);
      font-size: 1.2rem;
      font-weight: 600;
      cursor: pointer;
      transition: var(--transition);
      
      &:hover {
        border-color: var(--primary);
        color: var(--primary);
      }
      
      &:disabled {
        opacity: 0.5;
        cursor: not-allowed;
      }
    }
    
    .quantity-display {
      font-size: 1.2rem;
      font-weight: 600;
      color: var(--text-primary);
      min-width: 40px;
      text-align: center;
    }
  }
`;

const PriceSummary = styled.div`
  background: var(--bg-secondary);
  padding: 1.5rem;
  border-radius: var(--border-radius);
  margin-bottom: 1.5rem;
  
  .price-row {
    display: flex;
    justify-content: space-between;
    margin-bottom: 0.5rem;
    
    &:last-child {
      margin-bottom: 0;
      font-weight: 600;
      font-size: 1.1rem;
      color: var(--primary);
      border-top: 1px solid var(--border);
      padding-top: 0.5rem;
    }
  }
`;

const SubmitButton = styled.button`
  width: 100%;
  padding: 1rem;
  background: var(--primary);
  color: white;
  border: none;
  border-radius: var(--border-radius);
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  
  &:hover {
    background: var(--primary-dark);
  }
  
  &:disabled {
    background: var(--text-light);
    cursor: not-allowed;
  }
`;

const QRCodeSection = styled.div`
  text-align: center;
  padding: 2rem;
  background: var(--bg-secondary);
  border-radius: var(--border-radius);
  margin-top: 2rem;
  
  h3 {
    margin-bottom: 1rem;
    color: var(--text-primary);
  }
  
  .qr-container {
    display: flex;
    justify-content: center;
    margin-bottom: 1rem;
  }
  
  .ticket-id {
    font-family: monospace;
    font-size: 0.9rem;
    color: var(--text-secondary);
    background: var(--bg-primary);
    padding: 0.5rem 1rem;
    border-radius: var(--border-radius);
    display: inline-block;
  }
`;

const PurchaseModal = () => {
  const { purchaseModal, closePurchaseModal, processPurchase } = useAppContext();
  const [formData, setFormData] = useState({
    customer_name: '',
    customer_email: '',
    quantity: 1
  });
  const [isProcessing, setIsProcessing] = useState(false);
  const [purchaseResult, setPurchaseResult] = useState(null);

  const handleInputChange = (e) => {
    const { name, value } = e.target;
    setFormData(prev => ({
      ...prev,
      [name]: value
    }));
  };

  const handleQuantityChange = (delta) => {
    const newQuantity = Math.max(1, Math.min(10, formData.quantity + delta));
    setFormData(prev => ({
      ...prev,
      quantity: newQuantity
    }));
  };

  const handleSubmit = async (e) => {
    e.preventDefault();
    
    if (!formData.customer_name.trim() || !formData.customer_email.trim()) {
      return;
    }
    
    setIsProcessing(true);
    
    try {
      const result = await processPurchase({
        event_id: purchaseModal.event.id,
        section: purchaseModal.event.category,
        quantity: formData.quantity,
        customer_email: formData.customer_email,
        customer_name: formData.customer_name
      });
      
      setPurchaseResult(result);
    } catch (error) {
      console.error('Error processing purchase:', error);
    } finally {
      setIsProcessing(false);
    }
  };

  const handleClose = () => {
    setFormData({
      customer_name: '',
      customer_email: '',
      quantity: 1
    });
    setPurchaseResult(null);
    closePurchaseModal();
  };

  if (!purchaseModal.isOpen) return null;

  const totalPrice = purchaseModal.event ? purchaseModal.event.price * formData.quantity : 0;

  return (
    <AnimatePresence>
      <ModalOverlay
        initial={{ opacity: 0 }}
        animate={{ opacity: 1 }}
        exit={{ opacity: 0 }}
        onClick={handleClose}
      >
        <ModalContent
          initial={{ opacity: 0, scale: 0.8, y: 50 }}
          animate={{ opacity: 1, scale: 1, y: 0 }}
          exit={{ opacity: 0, scale: 0.8, y: 50 }}
          onClick={(e) => e.stopPropagation()}
        >
          <ModalHeader>
            <h2>Comprar Entradas</h2>
            <CloseButton onClick={handleClose}>
              <FaTimes />
            </CloseButton>
          </ModalHeader>

          <ModalBody>
            {!purchaseResult ? (
              <>
                {purchaseModal.event && (
                  <EventInfo>
                    <EventImage
                      src={purchaseModal.event.image_url}
                      alt={purchaseModal.event.title}
                    />
                    <EventDetails>
                      <h3>{purchaseModal.event.category}</h3>
                      <div className="event-info">
                        <div className="info-item">
                          <FaCalendar />
                          <span>{purchaseModal.event.date}</span>
                        </div>
                        <div className="info-item">
                          <FaMapMarkerAlt />
                          <span>{purchaseModal.event.location}</span>
                        </div>
                        <div className="info-item">
                          <FaTicketAlt />
                          <span>${purchaseModal.event.price} por entrada</span>
                        </div>
                      </div>
                    </EventDetails>
                  </EventInfo>
                )}

                <Form onSubmit={handleSubmit}>
                  <FormGroup>
                    <label className="form-label">Nombre completo</label>
                    <input
                      type="text"
                      name="customer_name"
                      className="form-input"
                      value={formData.customer_name}
                      onChange={handleInputChange}
                      required
                    />
                  </FormGroup>

                  <FormGroup>
                    <label className="form-label">Email</label>
                    <input
                      type="email"
                      name="customer_email"
                      className="form-input"
                      value={formData.customer_email}
                      onChange={handleInputChange}
                      required
                    />
                  </FormGroup>

                  <FormGroup>
                    <label className="form-label">Cantidad de entradas</label>
                    <div className="quantity-controls">
                      <button
                        type="button"
                        className="quantity-btn"
                        onClick={() => handleQuantityChange(-1)}
                        disabled={formData.quantity <= 1}
                      >
                        -
                      </button>
                      <span className="quantity-display">{formData.quantity}</span>
                      <button
                        type="button"
                        className="quantity-btn"
                        onClick={() => handleQuantityChange(1)}
                        disabled={formData.quantity >= 10}
                      >
                        +
                      </button>
                    </div>
                  </FormGroup>

                  <PriceSummary>
                    <div className="price-row">
                      <span>Precio por entrada:</span>
                      <span>${purchaseModal.event?.price}</span>
                    </div>
                    <div className="price-row">
                      <span>Cantidad:</span>
                      <span>{formData.quantity}</span>
                    </div>
                    <div className="price-row">
                      <span>Total:</span>
                      <span>${totalPrice}</span>
                    </div>
                  </PriceSummary>

                  <SubmitButton type="submit" disabled={isProcessing}>
                    {isProcessing ? 'Procesando...' : 'Confirmar Compra'}
                  </SubmitButton>
                </Form>
              </>
            ) : (
              <QRCodeSection>
                <h3>¡Compra Exitosa!</h3>
                <p>Tu entrada ha sido procesada correctamente</p>
                
                <div className="qr-container">
                  <QRCodeSVG
                    value={JSON.stringify({
                      ticket_id: purchaseResult.ticket_id,
                      event: purchaseModal.event?.title,
                      customer: purchaseResult.customer_email,
                      timestamp: new Date().toISOString()
                    })}
                    size={200}
                    level="M"
                  />
                </div>
                
                <div className="ticket-id">
                  {purchaseResult.ticket_id}
                </div>
                
                <p style={{ marginTop: '1rem', fontSize: '0.9rem', color: 'var(--text-secondary)' }}>
                  Guarda este QR code para acceder al evento
                </p>
              </QRCodeSection>
            )}
          </ModalBody>
        </ModalContent>
      </ModalOverlay>
    </AnimatePresence>
  );
};

export default PurchaseModal;
