// src/context/AppContext.jsx
import { createContext, useContext, useState, useEffect } from 'react';
import axios from 'axios';
import toast from 'react-hot-toast';

const AppContext = createContext();

export const useAppContext = () => {
  const context = useContext(AppContext);
  if (!context) {
    throw new Error('useAppContext must be used within an AppProvider');
  }
  return context;
};

// Vite: import.meta.env.VITE_API_BASE
// Fallback a '/api' para prod detrás de Nginx
const API_BASE = (import.meta?.env?.VITE_API_BASE) ?? '/api';

const api = axios.create({
  baseURL: API_BASE,         // <-- solo el prefijo
  headers: { 'Content-Type': 'application/json' },
});

export const AppProvider = ({ children }) => {
  const [events, setEvents] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredEvents, setFilteredEvents] = useState([]);
  const [purchaseModal, setPurchaseModal] = useState({ isOpen: false, event: null });

  useEffect(() => {
    const fetchData = async () => {
      try {
        const [eventsRes, categoriesRes] = await Promise.all([
          api.get('/events'),        // <-- sin /api
          api.get('/categories'),    // <-- sin /api
        ]);

        setEvents(eventsRes.data);
        setCategories(categoriesRes.data);
        setFilteredEvents(eventsRes.data);
      } catch (error) {
        console.error('Error fetching data:', error);
        toast.error('Error al cargar los datos');
      } finally {
        setLoading(false);
      }
    };

    fetchData();
  }, []);

  useEffect(() => {
    if (!searchQuery.trim()) {
      setFilteredEvents(events);
      return;
    }
    const filtered = events.filter(event =>
      event.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      event.location.toLowerCase().includes(searchQuery.toLowerCase()) ||
      event.category.toLowerCase().includes(searchQuery.toLowerCase())
    );
    setFilteredEvents(filtered);
  }, [searchQuery, events]);

  const openPurchaseModal = (event) => setPurchaseModal({ isOpen: true, event });
  const closePurchaseModal = () => setPurchaseModal({ isOpen: false, event: null });

  const processPurchase = async (purchaseData) => {
    try {
      const response = await api.post('/purchase', purchaseData); // <-- sin /api
      if (response.data.success) {
        toast.success(response.data.message || 'Compra procesada exitosamente');
        return response.data;
      }
      throw new Error(response.data.message || 'Error en la compra');
    } catch (error) {
      console.error('Error processing purchase:', error);
      if (error.response?.status === 422) {
        const detail = error.response.data?.detail;
        if (Array.isArray(detail)) {
          toast.error(`Error de validación: ${detail.map(e => e.msg).join(', ')}`);
        } else {
          toast.error('Error de validación en los datos enviados');
        }
      } else if (error.response?.status === 404) {
        toast.error('Evento no encontrado');
      } else if (error.response?.status === 400) {
        toast.error(error.response.data?.detail || 'Solicitud inválida');
      } else if (error.response?.status >= 500) {
        toast.error('Error del servidor. Por favor, intenta más tarde');
      } else if (error.response?.data?.detail) {
        toast.error(error.response.data.detail);
      } else if (error.message) {
        toast.error(error.message);
      } else {
        toast.error('Error al procesar la compra');
      }
      throw error;
    }
  };

  const subscribeNewsletter = async (email) => {
    try {
      const response = await api.post('/newsletter', { email }); // <-- sin /api
      toast.success('Suscrito exitosamente al newsletter');
      return response.data;
    } catch (error) {
      console.error('Error subscribing to newsletter:', error);
      toast.error('Error al suscribirse al newsletter');
      throw error;
    }
  };

  const value = {
    events,
    categories,
    loading,
    searchQuery,
    setSearchQuery,
    filteredEvents,
    purchaseModal,
    openPurchaseModal,
    closePurchaseModal,
    processPurchase,
    subscribeNewsletter,
  };

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
};
