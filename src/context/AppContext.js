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

export const AppProvider = ({ children }) => {
  const [events, setEvents] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredEvents, setFilteredEvents] = useState([]);
  const [purchaseModal, setPurchaseModal] = useState({
    isOpen: false,
    event: null
  });

  // Configurar axios
  axios.defaults.baseURL = process.env.REACT_APP_API_URL || 'http://localhost:8000';

  // Cargar datos iniciales
  useEffect(() => {
    const fetchData = async () => {
      try {
        const [eventsRes, categoriesRes] = await Promise.all([
          axios.get('/api/events'),
          axios.get('/api/categories')
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

  // Filtrar eventos por búsqueda
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

  // Función para abrir modal de compra
  const openPurchaseModal = (event) => {
    setPurchaseModal({
      isOpen: true,
      event
    });
  };

  // Función para cerrar modal de compra
  const closePurchaseModal = () => {
    setPurchaseModal({
      isOpen: false,
      event: null
    });
  };

  // Función para procesar compra
  const processPurchase = async (purchaseData) => {
    try {
      const response = await axios.post('/api/purchase', purchaseData);
      
      if (response.data.success) {
        toast.success(response.data.message || 'Compra procesada exitosamente');
        return response.data;
      } else {
        throw new Error(response.data.message || 'Error en la compra');
      }
    } catch (error) {
      console.error('Error processing purchase:', error);
      
      // Manejo específico de errores de validación
      if (error.response?.status === 422) {
        const validationErrors = error.response.data?.detail;
        if (Array.isArray(validationErrors)) {
          const errorMessages = validationErrors.map(err => err.msg).join(', ');
          toast.error(`Error de validación: ${errorMessages}`);
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

  // Función para suscribir al newsletter
  const subscribeNewsletter = async (email) => {
    try {
      const response = await axios.post('/api/newsletter', { email });
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
    subscribeNewsletter
  };

  return (
    <AppContext.Provider value={value}>
      {children}
    </AppContext.Provider>
  );
};
