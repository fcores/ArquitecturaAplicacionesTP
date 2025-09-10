import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FaCalendar, FaMapMarkerAlt, FaTicketAlt } from 'react-icons/fa';
import { useAppContext } from '../context/AppContext';

const EventsSection = styled.section`
  padding: var(--section-padding);
  background: var(--bg-secondary);
`;

const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
`;

const SectionHeader = styled.div`
  text-align: center;
  margin-bottom: 3rem;
  
  h2 {
    color: var(--text-primary);
    margin-bottom: 1rem;
  }
  
  p {
    color: var(--text-secondary);
    font-size: 1.1rem;
  }
`;

const EventsGrid = styled.div`
  display: grid;
  gap: 2rem;
  
  @media (min-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
    gap: 2.5rem;
  }
  
  @media (min-width: 1024px) {
    grid-template-columns: repeat(3, 1fr);
    gap: 3rem;
  }
`;

const EventCard = styled(motion.div)`
  background: var(--bg-primary);
  border-radius: var(--border-radius);
  overflow: hidden;
  box-shadow: var(--shadow);
  transition: var(--transition);
  cursor: pointer;
  
  &:hover {
    box-shadow: var(--shadow-hover);
    transform: translateY(-8px);
  }
`;

const EventImage = styled.div`
  position: relative;
  height: 200px;
  overflow: hidden;
  
  @media (min-width: 768px) {
    height: 220px;
  }
  
  img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    transition: var(--transition);
  }
  
  ${EventCard}:hover & img {
    transform: scale(1.1);
  }
`;

const EventBadge = styled.div`
  position: absolute;
  top: 1rem;
  right: 1rem;
  padding: 0.5rem 1rem;
  border-radius: 20px;
  font-size: 0.8rem;
  font-weight: 600;
  text-transform: uppercase;
  
  &.sold-out {
    background: var(--error);
    color: white;
  }
  
  &.available {
    background: var(--success);
    color: white;
  }
  
  &.coming-soon {
    background: var(--warning);
    color: white;
  }
`;

const EventDetails = styled.div`
  padding: 1.5rem;
  
  @media (min-width: 768px) {
    padding: 2rem;
  }
`;

const EventTitle = styled.h3`
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 1rem;
  
  @media (min-width: 768px) {
    font-size: 1.5rem;
  }
`;

const EventInfo = styled.div`
  display: flex;
  flex-direction: column;
  gap: 0.75rem;
  margin-bottom: 1.5rem;
`;

const EventInfoItem = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  color: var(--text-secondary);
  font-size: 0.9rem;
  
  svg {
    color: var(--primary);
    font-size: 1rem;
  }
`;

const EventPrice = styled.div`
  display: flex;
  align-items: center;
  justify-content: space-between;
  gap: 1rem;
`;

const Price = styled.span`
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
  
  @media (min-width: 768px) {
    font-size: 1.75rem;
  }
`;

const BuyButton = styled.button`
  padding: 0.75rem 1.5rem;
  background: var(--primary);
  color: white;
  border: none;
  border-radius: var(--border-radius);
  font-weight: 600;
  cursor: pointer;
  transition: var(--transition);
  white-space: nowrap;
  
  &:hover {
    background: var(--primary-dark);
    transform: translateY(-2px);
  }
  
  &:disabled {
    background: var(--text-light);
    cursor: not-allowed;
    transform: none;
  }
`;

const LoadingSpinner = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  padding: 4rem;
  
  &::after {
    content: '';
    width: 40px;
    height: 40px;
    border: 4px solid var(--border);
    border-top: 4px solid var(--primary);
    border-radius: 50%;
    animation: spin 1s linear infinite;
  }
  
  @keyframes spin {
    0% { transform: rotate(0deg); }
    100% { transform: rotate(360deg); }
  }
`;

const NoEvents = styled.div`
  text-align: center;
  padding: 4rem 2rem;
  color: var(--text-secondary);
  
  h3 {
    margin-bottom: 1rem;
  }
`;

const getBadgeClass = (status) => {
  switch (status.toLowerCase()) {
    case 'agotándose':
    case 'sold out':
      return 'sold-out';
    case 'disponible':
    case 'available':
      return 'available';
    case 'próximamente':
    case 'coming soon':
      return 'coming-soon';
    default:
      return 'available';
  }
};

const Events = () => {
  const { filteredEvents, loading, openPurchaseModal } = useAppContext();

  const handleEventClick = (event) => {
    openPurchaseModal(event);
  };

  if (loading) {
    return (
      <EventsSection id="events">
        <Container>
          <LoadingSpinner />
        </Container>
      </EventsSection>
    );
  }

  return (
    <EventsSection id="events">
      <Container>
        <SectionHeader>
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            Último Partido de Messi
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            viewport={{ once: true }}
          >
            El evento deportivo más esperado del año
          </motion.p>
        </SectionHeader>

        {filteredEvents.length === 0 ? (
          <NoEvents>
            <h3>No se encontraron eventos</h3>
            <p>Intenta con otros términos de búsqueda</p>
          </NoEvents>
        ) : (
          <EventsGrid>
            {filteredEvents.map((event, index) => (
              <EventCard
                key={event.id}
                initial={{ opacity: 0, y: 30 }}
                whileInView={{ opacity: 1, y: 0 }}
                transition={{ duration: 0.6, delay: index * 0.1 }}
                viewport={{ once: true }}
                onClick={() => handleEventClick(event)}
                whileHover={{ scale: 1.02 }}
              >
                <EventImage>
                  <img
                    src={event.image_url}
                    alt={event.title}
                    onError={(e) => {
                      e.target.src = '/images/placeholder.svg';
                    }}
                  />
                  <EventBadge className={getBadgeClass(event.status)}>
                    {event.status}
                  </EventBadge>
                </EventImage>
                
                <EventDetails>
                  <EventTitle>{event.category}</EventTitle>
                  
                  <EventInfo>
                    <EventInfoItem>
                      <FaCalendar />
                      <span>{event.date}</span>
                    </EventInfoItem>
                    <EventInfoItem>
                      <FaMapMarkerAlt />
                      <span>{event.location}</span>
                    </EventInfoItem>
                  </EventInfo>
                  
                  <EventPrice>
                    <Price>${event.price}</Price>
                    <BuyButton
                      disabled={event.status.toLowerCase().includes('agot') || event.status.toLowerCase().includes('sold')}
                      onClick={(e) => {
                        e.stopPropagation();
                        handleEventClick(event);
                      }}
                    >
                      Comprar
                    </BuyButton>
                  </EventPrice>
                </EventDetails>
              </EventCard>
            ))}
          </EventsGrid>
        )}
      </Container>
    </EventsSection>
  );
};

export default Events;
