// src/context/AppContext.js
import { createContext, useContext, useEffect, useMemo, useState } from 'react';
import axios from 'axios';
import toast from 'react-hot-toast';

const AppContext = createContext(undefined);

// Helper para normalizar el baseURL (sin barra final)
function computeBaseURL() {
  // 1) Tomá env en build-time (CRA) o usá /api por defecto (reverse proxy)
  let url = (process.env.REACT_APP_API_URL || '/api').replace(/\/+$/, '');

  // 2) Guard de seguridad: si por algún motivo quedó 'localhost' en prod, fuerza /api
  if (
    /^https?:\/\/localhost(?::\d+)?/i.test(url) &&
    typeof window !== 'undefined' &&
    window.location.hostname !== 'localhost'
  ) {
    url = '/api';
  }

  return url;
}
// Axios instance
const api = axios.create({
  baseURL: computeBaseURL(), // p.ej. '/api'
  timeout: 15000,
  withCredentials: false,
});

// Interceptor de respuesta: deja sólo data y mapea errores comunes
api.interceptors.response.use(
  (res) => res,
  (err) => {
    // Dejá pasar el error para que lo maneje el caller
    return Promise.reject(err);
  }
);

export const useAppContext = () => {
  const ctx = useContext(AppContext);
  if (!ctx) throw new Error('useAppContext must be used within an AppProvider');
  return ctx;
};

export const AppProvider = ({ children }) => {
  const [events, setEvents] = useState([]);
  const [categories, setCategories] = useState([]);
  const [loading, setLoading] = useState(true);
  const [searchQuery, setSearchQuery] = useState('');
  const [filteredEvents, setFilteredEvents] = useState([]);
  const [purchaseModal, setPurchaseModal] = useState({ isOpen: false, event: null });

  // Sólo para debug rápido en consola
  useEffect(() => {
    // eslint-disable-next-line no-console
    console.log('[AppContext] API baseURL =>', api.defaults.baseURL);
  }, []);

  // Cargar datos iniciales
  useEffect(() => {
    let cancelled = false;

    async function load() {
      setLoading(true);
      try {
        // ¡OJO! Rutas relativas al baseURL -> 'events', 'categories'
        const [eventsRes, categoriesRes] = await Promise.all([
          api.get('events'),
          api.get('categories'),
        ]);

        if (cancelled) return;
        setEvents(eventsRes.data);
        setCategories(categoriesRes.data);
        setFilteredEvents(eventsRes.data);
      } catch (error) {
        // eslint-disable-next-line no-console
        console.error('Error fetching data:', error);
        toast.error('Error al cargar los datos');
      } finally {
        if (!cancelled) setLoading(false);
      }
    }

    load();
    return () => {
      cancelled = true;
    };
  }, []);

  // Filtrar eventos por búsqueda
  useEffect(() => {
    const q = searchQuery.trim().toLowerCase();
    if (!q) {
      setFilteredEvents(events);
      return;
    }
    setFilteredEvents(
      events.filter(
        (e) =>
          e.title?.toLowerCase().includes(q) ||
          e.location?.toLowerCase().includes(q) ||
          e.category?.toLowerCase().includes(q)
      )
    );
  }, [searchQuery, events]);

  // Modal
  const openPurchaseModal = (event) => setPurchaseModal({ isOpen: true, event });
  const closePurchaseModal = () => setPurchaseModal({ isOpen: false, event: null });

  // Comprar
  const processPurchase = async (purchaseData) => {
    try {
      // Ruta relativa al baseURL -> 'purchase'
      const { data } = await api.post('purchase', purchaseData);

      if (data?.success) {
        toast.success(data.message || 'Compra procesada exitosamente');
        return data;
      }
      throw new Error(data?.message || 'Error en la compra');
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Error processing purchase:', error);

      const status = error?.response?.status;
      const detail = error?.response?.data?.detail;

      if (status === 422) {
        const errs = error?.response?.data?.detail;
        if (Array.isArray(errs)) {
          const msg = errs.map((e) => e.msg).join(', ');
          toast.error(`Error de validación: ${msg}`);
        } else {
          toast.error('Error de validación en los datos enviados');
        }
      } else if (status === 404) {
        toast.error('Evento no encontrado');
      } else if (status === 400) {
        toast.error(detail || 'Solicitud inválida');
      } else if (status >= 500) {
        toast.error('Error del servidor. Por favor, intenta más tarde');
      } else if (detail) {
        toast.error(detail);
      } else if (error.message) {
        toast.error(error.message);
      } else {
        toast.error('Error al procesar la compra');
      }

      throw error;
    }
  };

  // Newsletter
  const subscribeNewsletter = async (email) => {
    try {
      const { data } = await api.post('newsletter', { email });
      toast.success('Suscrito exitosamente al newsletter');
      return data;
    } catch (error) {
      // eslint-disable-next-line no-console
      console.error('Error subscribing to newsletter:', error);
      toast.error('Error al suscribirse al newsletter');
      throw error;
    }
  };

  // (Opcional) health check simple para debug
  const ping = async () => {
    try {
      const { data } = await api.get('healthz'); // /api/healthz
      return data;
    } catch (e) {
      return null;
    }
  };

  const value = useMemo(
    () => ({
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
      ping,
      apiBaseURL: api.defaults.baseURL,
    }),
    [
      events,
      categories,
      loading,
      searchQuery,
      filteredEvents,
      purchaseModal,
    ]
  );

  return <AppContext.Provider value={value}>{children}</AppContext.Provider>;
};
