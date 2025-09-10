import { createGlobalStyle } from 'styled-components';

export const GlobalStyles = createGlobalStyle`
  * {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
  }

  html {
    font-size: 16px;
    scroll-behavior: smooth;
  }

  body {
    font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', 'Roboto', 'Oxygen',
      'Ubuntu', 'Cantarell', 'Fira Sans', 'Droid Sans', 'Helvetica Neue', sans-serif;
    -webkit-font-smoothing: antialiased;
    -moz-osx-font-smoothing: grayscale;
    line-height: 1.6;
    color: #333;
    background-color: #f8f9fa;
  }

  /* Mobile-first responsive breakpoints */
  :root {
    --container-padding: 1rem;
    --section-padding: 2rem 1rem;
    --border-radius: 12px;
    --shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
    --shadow-hover: 0 8px 25px rgba(0, 0, 0, 0.15);
    --transition: all 0.3s ease;
    
    /* Colors */
    --primary: #2563eb;
    --primary-dark: #1d4ed8;
    --secondary: #f59e0b;
    --accent: #dc2626;
    --success: #10b981;
    --warning: #f59e0b;
    --error: #ef4444;
    
    --text-primary: #1f2937;
    --text-secondary: #6b7280;
    --text-light: #9ca3af;
    
    --bg-primary: #ffffff;
    --bg-secondary: #f8f9fa;
    --bg-dark: #1f2937;
    
    --border: #e5e7eb;
    --border-light: #f3f4f6;
  }

  /* Tablet */
  @media (min-width: 768px) {
    :root {
      --container-padding: 2rem;
      --section-padding: 3rem 2rem;
    }
  }

  /* Desktop */
  @media (min-width: 1024px) {
    :root {
      --container-padding: 3rem;
      --section-padding: 4rem 3rem;
    }
  }

  /* Large Desktop */
  @media (min-width: 1280px) {
    :root {
      --container-padding: 4rem;
      --section-padding: 5rem 4rem;
    }
  }

  /* Container */
  .container {
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 var(--container-padding);
  }

  /* Typography */
  h1, h2, h3, h4, h5, h6 {
    font-weight: 600;
    line-height: 1.2;
    margin-bottom: 1rem;
  }

  h1 {
    font-size: 2rem;
    @media (min-width: 768px) { font-size: 2.5rem; }
    @media (min-width: 1024px) { font-size: 3rem; }
  }

  h2 {
    font-size: 1.75rem;
    @media (min-width: 768px) { font-size: 2rem; }
    @media (min-width: 1024px) { font-size: 2.25rem; }
  }

  h3 {
    font-size: 1.5rem;
    @media (min-width: 768px) { font-size: 1.75rem; }
  }

  p {
    margin-bottom: 1rem;
    color: var(--text-secondary);
  }

  /* Buttons */
  .btn {
    display: inline-flex;
    align-items: center;
    justify-content: center;
    padding: 0.75rem 1.5rem;
    border: none;
    border-radius: var(--border-radius);
    font-size: 1rem;
    font-weight: 500;
    text-decoration: none;
    cursor: pointer;
    transition: var(--transition);
    gap: 0.5rem;
    
    &:hover {
      transform: translateY(-2px);
    }
    
    &:active {
      transform: translateY(0);
    }
  }

  .btn-primary {
    background: var(--primary);
    color: white;
    
    &:hover {
      background: var(--primary-dark);
    }
  }

  .btn-secondary {
    background: var(--secondary);
    color: white;
    
    &:hover {
      background: #d97706;
    }
  }

  .btn-outline {
    background: transparent;
    color: var(--primary);
    border: 2px solid var(--primary);
    
    &:hover {
      background: var(--primary);
      color: white;
    }
  }

  /* Forms */
  .form-group {
    margin-bottom: 1.5rem;
  }

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

  /* Cards */
  .card {
    background: var(--bg-primary);
    border-radius: var(--border-radius);
    box-shadow: var(--shadow);
    transition: var(--transition);
    overflow: hidden;
    
    &:hover {
      box-shadow: var(--shadow-hover);
      transform: translateY(-4px);
    }
  }

  /* Grid */
  .grid {
    display: grid;
    gap: 1.5rem;
  }

  .grid-1 { grid-template-columns: 1fr; }
  .grid-2 { grid-template-columns: repeat(2, 1fr); }
  .grid-3 { grid-template-columns: repeat(3, 1fr); }
  .grid-4 { grid-template-columns: repeat(4, 1fr); }

  @media (min-width: 768px) {
    .grid-md-2 { grid-template-columns: repeat(2, 1fr); }
    .grid-md-3 { grid-template-columns: repeat(3, 1fr); }
    .grid-md-4 { grid-template-columns: repeat(4, 1fr); }
  }

  @media (min-width: 1024px) {
    .grid-lg-2 { grid-template-columns: repeat(2, 1fr); }
    .grid-lg-3 { grid-template-columns: repeat(3, 1fr); }
    .grid-lg-4 { grid-template-columns: repeat(4, 1fr); }
  }

  /* Utilities */
  .text-center { text-align: center; }
  .text-left { text-align: left; }
  .text-right { text-align: right; }
  
  .mb-1 { margin-bottom: 0.5rem; }
  .mb-2 { margin-bottom: 1rem; }
  .mb-3 { margin-bottom: 1.5rem; }
  .mb-4 { margin-bottom: 2rem; }
  
  .mt-1 { margin-top: 0.5rem; }
  .mt-2 { margin-top: 1rem; }
  .mt-3 { margin-top: 1.5rem; }
  .mt-4 { margin-top: 2rem; }
  
  .p-1 { padding: 0.5rem; }
  .p-2 { padding: 1rem; }
  .p-3 { padding: 1.5rem; }
  .p-4 { padding: 2rem; }

  /* Animations */
  @keyframes fadeInUp {
    from {
      opacity: 0;
      transform: translateY(30px);
    }
    to {
      opacity: 1;
      transform: translateY(0);
    }
  }

  @keyframes fadeIn {
    from {
      opacity: 0;
    }
    to {
      opacity: 1;
    }
  }

  .fade-in-up {
    animation: fadeInUp 0.6s ease forwards;
  }

  .fade-in {
    animation: fadeIn 0.6s ease forwards;
  }

  /* Scrollbar */
  ::-webkit-scrollbar {
    width: 8px;
  }

  ::-webkit-scrollbar-track {
    background: var(--bg-secondary);
  }

  ::-webkit-scrollbar-thumb {
    background: var(--border);
    border-radius: 4px;
  }

  ::-webkit-scrollbar-thumb:hover {
    background: var(--text-light);
  }
`;
