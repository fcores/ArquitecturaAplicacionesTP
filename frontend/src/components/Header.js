import React, { useState, useEffect } from 'react';
import styled from 'styled-components';
import { FaTicketAlt, FaBars, FaTimes } from 'react-icons/fa';
import { motion, AnimatePresence } from 'framer-motion';

const HeaderContainer = styled.header`
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  z-index: 1000;
  background: rgba(255, 255, 255, 0.95);
  backdrop-filter: blur(10px);
  border-bottom: 1px solid var(--border);
  transition: var(--transition);
  
  &.scrolled {
    background: rgba(255, 255, 255, 0.98);
    box-shadow: 0 2px 20px rgba(0, 0, 0, 0.1);
  }
`;

const Nav = styled.nav`
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 var(--container-padding);
  display: flex;
  align-items: center;
  justify-content: space-between;
  height: 70px;
  
  @media (min-width: 768px) {
    height: 80px;
  }
`;

const Brand = styled.div`
  display: flex;
  align-items: center;
  gap: 0.5rem;
  font-size: 1.5rem;
  font-weight: 700;
  color: var(--primary);
  
  svg {
    font-size: 1.75rem;
  }
  
  @media (min-width: 768px) {
    font-size: 1.75rem;
    
    svg {
      font-size: 2rem;
    }
  }
`;

const NavMenu = styled.ul`
  display: none;
  list-style: none;
  gap: 2rem;
  
  @media (min-width: 768px) {
    display: flex;
  }
`;

const NavItem = styled.li`
  a {
    color: var(--text-primary);
    text-decoration: none;
    font-weight: 500;
    transition: var(--transition);
    position: relative;
    
    &:hover {
      color: var(--primary);
    }
    
    &::after {
      content: '';
      position: absolute;
      bottom: -5px;
      left: 0;
      width: 0;
      height: 2px;
      background: var(--primary);
      transition: var(--transition);
    }
    
    &:hover::after {
      width: 100%;
    }
  }
`;

const MobileToggle = styled.button`
  display: flex;
  flex-direction: column;
  background: none;
  border: none;
  cursor: pointer;
  padding: 0.5rem;
  gap: 4px;
  
  @media (min-width: 768px) {
    display: none;
  }
  
  span {
    width: 25px;
    height: 3px;
    background: var(--text-primary);
    transition: var(--transition);
    border-radius: 2px;
  }
  
  &.active span:nth-child(1) {
    transform: rotate(45deg) translate(6px, 6px);
  }
  
  &.active span:nth-child(2) {
    opacity: 0;
  }
  
  &.active span:nth-child(3) {
    transform: rotate(-45deg) translate(6px, -6px);
  }
`;

const MobileMenu = styled(motion.div)`
  position: fixed;
  top: 70px;
  left: 0;
  right: 0;
  background: var(--bg-primary);
  border-bottom: 1px solid var(--border);
  box-shadow: 0 4px 20px rgba(0, 0, 0, 0.1);
  
  @media (min-width: 768px) {
    display: none;
  }
`;

const MobileNavMenu = styled.ul`
  list-style: none;
  padding: 1rem var(--container-padding);
  
  li {
    margin-bottom: 1rem;
    
    &:last-child {
      margin-bottom: 0;
    }
    
    a {
      display: block;
      padding: 1rem;
      color: var(--text-primary);
      text-decoration: none;
      font-weight: 500;
      border-radius: var(--border-radius);
      transition: var(--transition);
      
      &:hover {
        background: var(--bg-secondary);
        color: var(--primary);
      }
    }
  }
`;

const Header = () => {
  const [isMenuOpen, setIsMenuOpen] = useState(false);
  const [isScrolled, setIsScrolled] = useState(false);

  useEffect(() => {
    const handleScroll = () => {
      setIsScrolled(window.scrollY > 50);
    };

    window.addEventListener('scroll', handleScroll);
    return () => window.removeEventListener('scroll', handleScroll);
  }, []);

  const toggleMenu = () => {
    setIsMenuOpen(!isMenuOpen);
  };

  const closeMenu = () => {
    setIsMenuOpen(false);
  };

  const scrollToSection = (sectionId) => {
    const element = document.getElementById(sectionId);
    if (element) {
      element.scrollIntoView({ behavior: 'smooth' });
    }
    closeMenu();
  };

  return (
    <HeaderContainer className={isScrolled ? 'scrolled' : ''}>
      <Nav>
        <Brand>
          <FaTicketAlt />
          <span>TicketPardo</span>
        </Brand>

        <NavMenu>
          <NavItem>
            <a href="#home" onClick={(e) => { e.preventDefault(); scrollToSection('home'); }}>
              Inicio
            </a>
          </NavItem>
          <NavItem>
            <a href="#events" onClick={(e) => { e.preventDefault(); scrollToSection('events'); }}>
              Eventos
            </a>
          </NavItem>
          <NavItem>
            <a href="#about" onClick={(e) => { e.preventDefault(); scrollToSection('about'); }}>
              Nosotros
            </a>
          </NavItem>
          <NavItem>
            <a href="#contact" onClick={(e) => { e.preventDefault(); scrollToSection('contact'); }}>
              Contacto
            </a>
          </NavItem>
        </NavMenu>

        <MobileToggle 
          className={isMenuOpen ? 'active' : ''} 
          onClick={toggleMenu}
          aria-label="Toggle menu"
        >
          <span></span>
          <span></span>
          <span></span>
        </MobileToggle>
      </Nav>

      <AnimatePresence>
        {isMenuOpen && (
          <MobileMenu
            initial={{ opacity: 0, height: 0 }}
            animate={{ opacity: 1, height: 'auto' }}
            exit={{ opacity: 0, height: 0 }}
            transition={{ duration: 0.3 }}
          >
            <MobileNavMenu>
              <li>
                <a href="#home" onClick={(e) => { e.preventDefault(); scrollToSection('home'); }}>
                  Inicio
                </a>
              </li>
              <li>
                <a href="#events" onClick={(e) => { e.preventDefault(); scrollToSection('events'); }}>
                  Eventos
                </a>
              </li>
              <li>
                <a href="#about" onClick={(e) => { e.preventDefault(); scrollToSection('about'); }}>
                  Nosotros
                </a>
              </li>
              <li>
                <a href="#contact" onClick={(e) => { e.preventDefault(); scrollToSection('contact'); }}>
                  Contacto
                </a>
              </li>
            </MobileNavMenu>
          </MobileMenu>
        )}
      </AnimatePresence>
    </HeaderContainer>
  );
};

export default Header;
