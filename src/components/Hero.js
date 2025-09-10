import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FaSearch, FaQrcode } from 'react-icons/fa';
import { useAppContext } from '../context/AppContext';

const HeroSection = styled.section`
  min-height: 100vh;
  display: flex;
  align-items: center;
  background: linear-gradient(135deg, var(--primary) 0%, var(--primary-dark) 100%);
  color: white;
  padding: var(--section-padding);
  padding-top: calc(70px + 2rem);
  
  @media (min-width: 768px) {
    padding-top: calc(80px + 3rem);
  }
`;

const HeroContainer = styled.div`
  max-width: 1200px;
  margin: 0 auto;
  width: 100%;
  display: grid;
  gap: 3rem;
  
  @media (min-width: 1024px) {
    grid-template-columns: 1fr 1fr;
    align-items: center;
    gap: 4rem;
  }
`;

const HeroContent = styled.div`
  text-align: center;
  
  @media (min-width: 1024px) {
    text-align: left;
  }
`;

const HeroTitle = styled(motion.h1)`
  font-size: 2.5rem;
  font-weight: 700;
  margin-bottom: 1rem;
  line-height: 1.1;
  
  @media (min-width: 768px) {
    font-size: 3rem;
  }
  
  @media (min-width: 1024px) {
    font-size: 3.5rem;
  }
`;

const HeroSubtitle = styled(motion.p)`
  font-size: 1.1rem;
  margin-bottom: 2rem;
  opacity: 0.9;
  line-height: 1.6;
  
  @media (min-width: 768px) {
    font-size: 1.25rem;
  }
`;

const SearchContainer = styled(motion.div)`
  display: flex;
  flex-direction: column;
  gap: 1rem;
  margin-bottom: 2rem;
  
  @media (min-width: 768px) {
    flex-direction: row;
    max-width: 500px;
    margin: 0 auto 2rem auto;
  }
  
  @media (min-width: 1024px) {
    margin: 0 0 2rem 0;
  }
`;

const SearchInput = styled.input`
  flex: 1;
  padding: 1rem 1.5rem;
  border: none;
  border-radius: var(--border-radius);
  font-size: 1rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  backdrop-filter: blur(10px);
  
  &::placeholder {
    color: rgba(255, 255, 255, 0.7);
  }
  
  &:focus {
    outline: none;
    background: rgba(255, 255, 255, 0.15);
  }
`;

const SearchButton = styled.button`
  padding: 1rem 1.5rem;
  background: var(--secondary);
  color: white;
  border: none;
  border-radius: var(--border-radius);
  font-size: 1rem;
  font-weight: 500;
  cursor: pointer;
  transition: var(--transition);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  
  &:hover {
    background: #d97706;
    transform: translateY(-2px);
  }
`;

const TestButton = styled(motion.button)`
  padding: 0.75rem 1.5rem;
  background: rgba(255, 255, 255, 0.1);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: var(--border-radius);
  font-size: 0.9rem;
  cursor: pointer;
  transition: var(--transition);
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 0.5rem;
  backdrop-filter: blur(10px);
  
  &:hover {
    background: rgba(255, 255, 255, 0.2);
    border-color: rgba(255, 255, 255, 0.5);
  }
`;

const HeroImage = styled.div`
  display: flex;
  justify-content: center;
  align-items: center;
  
  @media (min-width: 1024px) {
    justify-content: flex-end;
  }
`;

const FloatingCard = styled(motion.div)`
  background: rgba(255, 255, 255, 0.1);
  backdrop-filter: blur(20px);
  border-radius: var(--border-radius);
  padding: 1.5rem;
  border: 1px solid rgba(255, 255, 255, 0.2);
  max-width: 350px;
  width: 100%;
  
  @media (min-width: 768px) {
    max-width: 400px;
    padding: 2rem;
  }
`;

const EventPreview = styled.div`
  display: flex;
  gap: 1rem;
  align-items: center;
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

const EventInfo = styled.div`
  flex: 1;
  
  h3 {
    font-size: 1.1rem;
    font-weight: 600;
    margin-bottom: 0.5rem;
    
    @media (min-width: 768px) {
      font-size: 1.25rem;
    }
  }
  
  p {
    font-size: 0.9rem;
    opacity: 0.8;
    margin-bottom: 0.5rem;
  }
  
  .price {
    font-size: 1.1rem;
    font-weight: 600;
    color: var(--secondary);
  }
`;

const Hero = () => {
  const { setSearchQuery } = useAppContext();

  const handleSearch = (e) => {
    e.preventDefault();
    const query = e.target.search.value;
    if (query.trim()) {
      setSearchQuery(query);
      document.getElementById('events')?.scrollIntoView({ behavior: 'smooth' });
    }
  };

  const testQRCode = () => {
    // Función para probar QR code
    console.log('Testing QR Code functionality');
  };

  return (
    <HeroSection id="home">
      <HeroContainer>
        <HeroContent>
          <HeroTitle
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8 }}
          >
            Último Partido de Messi
          </HeroTitle>
          
          <HeroSubtitle
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.2 }}
          >
            El adiós del GOAT del fútbol. No te pierdas este momento histórico
          </HeroSubtitle>
          
          <SearchContainer
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.4 }}
            as="form"
            onSubmit={handleSearch}
          >
            <SearchInput
              type="text"
              name="search"
              placeholder="Buscar entradas, categorías o ubicaciones..."
            />
            <SearchButton type="submit">
              <FaSearch />
              Buscar
            </SearchButton>
          </SearchContainer>
          
          <TestButton
            initial={{ opacity: 0, y: 30 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.8, delay: 0.6 }}
            onClick={testQRCode}
          >
            <FaQrcode />
            Probar QR
          </TestButton>
        </HeroContent>
        
        <HeroImage>
          <FloatingCard
            initial={{ opacity: 0, scale: 0.8 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ duration: 0.8, delay: 0.8 }}
            whileHover={{ scale: 1.05 }}
          >
            <EventPreview>
              <EventImage
                src="https://images.unsplash.com/photo-1571019613454-1cb2f99b2d8b?w=400&h=250&fit=crop"
                alt="Estadio de Fútbol"
                onError={(e) => {
                  e.target.src = '/images/placeholder.svg';
                }}
              />
              <EventInfo>
                <h3>Messi vs. Selección Mundial</h3>
                <p>15 de Diciembre • Estadio Monumental</p>
                <span className="price">Desde $150</span>
              </EventInfo>
            </EventPreview>
          </FloatingCard>
        </HeroImage>
      </HeroContainer>
    </HeroSection>
  );
};

export default Hero;
