import React from 'react';
import styled from 'styled-components';
import { FaTicketAlt, FaFacebook, FaTwitter, FaInstagram, FaYoutube, FaPhone, FaEnvelope, FaMapMarkerAlt } from 'react-icons/fa';

const FooterContainer = styled.footer`
  background: var(--bg-dark);
  color: white;
  padding: var(--section-padding);
`;

const Container = styled.div`
  max-width: 1200px;
  margin: 0 auto;
`;

const FooterContent = styled.div`
  display: grid;
  gap: 2rem;
  margin-bottom: 2rem;
  
  @media (min-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
    gap: 3rem;
  }
  
  @media (min-width: 1024px) {
    grid-template-columns: repeat(4, 1fr);
    gap: 4rem;
  }
`;

const FooterSection = styled.div`
  h3, h4 {
    color: white;
    margin-bottom: 1rem;
    font-size: 1.25rem;
    
    @media (min-width: 768px) {
      font-size: 1.5rem;
    }
  }
  
  h4 {
    font-size: 1.1rem;
    
    @media (min-width: 768px) {
      font-size: 1.25rem;
    }
  }
  
  p {
    color: rgba(255, 255, 255, 0.8);
    line-height: 1.6;
    margin-bottom: 1rem;
  }
`;

const BrandSection = styled(FooterSection)`
  .brand {
    display: flex;
    align-items: center;
    gap: 0.5rem;
    font-size: 1.5rem;
    font-weight: 700;
    margin-bottom: 1rem;
    
    @media (min-width: 768px) {
      font-size: 1.75rem;
    }
    
    svg {
      color: var(--primary);
    }
  }
`;

const SocialLinks = styled.div`
  display: flex;
  gap: 1rem;
  margin-top: 1rem;
  
  a {
    width: 40px;
    height: 40px;
    background: rgba(255, 255, 255, 0.1);
    border-radius: 50%;
    display: flex;
    align-items: center;
    justify-content: center;
    color: white;
    text-decoration: none;
    transition: var(--transition);
    
    &:hover {
      background: var(--primary);
      transform: translateY(-2px);
    }
  }
`;

const FooterLinks = styled.ul`
  list-style: none;
  
  li {
    margin-bottom: 0.75rem;
    
    a {
      color: rgba(255, 255, 255, 0.8);
      text-decoration: none;
      transition: var(--transition);
      
      &:hover {
        color: var(--primary);
      }
    }
  }
`;

const ContactInfo = styled.div`
  .contact-item {
    display: flex;
    align-items: center;
    gap: 0.75rem;
    margin-bottom: 1rem;
    color: rgba(255, 255, 255, 0.8);
    
    svg {
      color: var(--primary);
      font-size: 1.1rem;
    }
  }
`;

const FooterBottom = styled.div`
  border-top: 1px solid rgba(255, 255, 255, 0.1);
  padding-top: 2rem;
  text-align: center;
  
  p {
    color: rgba(255, 255, 255, 0.6);
    font-size: 0.9rem;
  }
`;

const Footer = () => {
  return (
    <FooterContainer id="contact">
      <Container>
        <FooterContent>
          <BrandSection>
            <div className="brand">
              <FaTicketAlt />
              <span>TicketPardo</span>
            </div>
            <p>
              Entradas oficiales para el último partido de Messi. Evento histórico del fútbol mundial.
            </p>
            <SocialLinks>
              <a href="#" aria-label="Facebook">
                <FaFacebook />
              </a>
              <a href="#" aria-label="Twitter">
                <FaTwitter />
              </a>
              <a href="#" aria-label="Instagram">
                <FaInstagram />
              </a>
              <a href="#" aria-label="YouTube">
                <FaYoutube />
              </a>
            </SocialLinks>
          </BrandSection>

          <FooterSection>
            <h4>Enlaces Rápidos</h4>
            <FooterLinks>
              <li><a href="#home">Inicio</a></li>
              <li><a href="#events">Entradas</a></li>
              <li><a href="#about">Información</a></li>
              <li><a href="#contact">Contacto</a></li>
            </FooterLinks>
          </FooterSection>

          <FooterSection>
            <h4>Soporte</h4>
            <FooterLinks>
              <li><a href="#">Centro de Ayuda</a></li>
              <li><a href="#">Contacto</a></li>
              <li><a href="#">Términos y Condiciones</a></li>
              <li><a href="#">Política de Privacidad</a></li>
            </FooterLinks>
          </FooterSection>

          <FooterSection>
            <h4>Contacto</h4>
            <ContactInfo>
              <div className="contact-item">
                <FaPhone />
                <span>+54 11 1234-5678</span>
              </div>
              <div className="contact-item">
                <FaEnvelope />
                <span>info@ticketpardo.com</span>
              </div>
              <div className="contact-item">
                <FaMapMarkerAlt />
                <span>Buenos Aires, Argentina</span>
              </div>
            </ContactInfo>
          </FooterSection>
        </FooterContent>

        <FooterBottom>
          <p>&copy; 2024 TicketPardo. Entradas oficiales para el último partido de Messi.</p>
        </FooterBottom>
      </Container>
    </FooterContainer>
  );
};

export default Footer;
