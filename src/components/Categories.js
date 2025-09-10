import React from 'react';
import styled from 'styled-components';
import { motion } from 'framer-motion';
import { FaStar, FaEye, FaMountain, FaUsers } from 'react-icons/fa';

const CategoriesSection = styled.section`
  padding: var(--section-padding);
  background: var(--bg-primary);
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

const CategoriesGrid = styled.div`
  display: grid;
  gap: 2rem;
  
  @media (min-width: 768px) {
    grid-template-columns: repeat(2, 1fr);
    gap: 2.5rem;
  }
  
  @media (min-width: 1024px) {
    grid-template-columns: repeat(4, 1fr);
    gap: 3rem;
  }
`;

const CategoryCard = styled(motion.div)`
  background: var(--bg-secondary);
  border-radius: var(--border-radius);
  padding: 2rem;
  text-align: center;
  transition: var(--transition);
  cursor: pointer;
  border: 2px solid transparent;
  
  &:hover {
    background: var(--bg-primary);
    border-color: var(--primary);
    transform: translateY(-8px);
    box-shadow: var(--shadow-hover);
  }
  
  @media (min-width: 768px) {
    padding: 2.5rem;
  }
`;

const CategoryIcon = styled.div`
  width: 80px;
  height: 80px;
  background: var(--primary);
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
  transition: var(--transition);
  
  svg {
    font-size: 2rem;
    color: white;
  }
  
  ${CategoryCard}:hover & {
    background: var(--secondary);
    transform: scale(1.1);
  }
  
  @media (min-width: 768px) {
    width: 100px;
    height: 100px;
    
    svg {
      font-size: 2.5rem;
    }
  }
`;

const CategoryTitle = styled.h3`
  font-size: 1.25rem;
  font-weight: 600;
  color: var(--text-primary);
  margin-bottom: 1rem;
  
  @media (min-width: 768px) {
    font-size: 1.5rem;
  }
`;

const CategoryDescription = styled.p`
  color: var(--text-secondary);
  line-height: 1.6;
  font-size: 0.95rem;
  
  @media (min-width: 768px) {
    font-size: 1rem;
  }
`;

const categories = [
  {
    id: 1,
    name: "Platea Preferencial",
    icon: FaStar,
    description: "Vista privilegiada del campo"
  },
  {
    id: 2,
    name: "Platea Media",
    icon: FaEye,
    description: "Excelente vista panorámica"
  },
  {
    id: 3,
    name: "Platea Alta",
    icon: FaMountain,
    description: "Vista completa del estadio"
  },
  {
    id: 4,
    name: "Gradas Populares",
    icon: FaUsers,
    description: "Ambiente de pasión futbolera"
  }
];

const Categories = () => {
  return (
    <CategoriesSection id="categories">
      <Container>
        <SectionHeader>
          <motion.h2
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6 }}
            viewport={{ once: true }}
          >
            Tipos de Entradas
          </motion.h2>
          <motion.p
            initial={{ opacity: 0, y: 30 }}
            whileInView={{ opacity: 1, y: 0 }}
            transition={{ duration: 0.6, delay: 0.2 }}
            viewport={{ once: true }}
          >
            Elige la mejor ubicación para ver el último partido de Messi
          </motion.p>
        </SectionHeader>

        <CategoriesGrid>
          {categories.map((category, index) => (
            <CategoryCard
              key={category.id}
              initial={{ opacity: 0, y: 30 }}
              whileInView={{ opacity: 1, y: 0 }}
              transition={{ duration: 0.6, delay: index * 0.1 }}
              viewport={{ once: true }}
              whileHover={{ scale: 1.05 }}
            >
              <CategoryIcon>
                <category.icon />
              </CategoryIcon>
              <CategoryTitle>{category.name}</CategoryTitle>
              <CategoryDescription>{category.description}</CategoryDescription>
            </CategoryCard>
          ))}
        </CategoriesGrid>
      </Container>
    </CategoriesSection>
  );
};

export default Categories;
