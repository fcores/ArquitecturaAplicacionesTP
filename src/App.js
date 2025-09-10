import React from 'react';
import { Routes, Route } from 'react-router-dom';
import Header from './components/Header';
import Hero from './components/Hero';
import Events from './components/Events';
import Categories from './components/Categories';
import Newsletter from './components/Newsletter';
import Footer from './components/Footer';
import PurchaseModal from './components/PurchaseModal';
import { AppProvider } from './context/AppContext';

function App() {
  return (
    <AppProvider>
      <div className="App">
        <Header />
        <main>
          <Routes>
            <Route path="/" element={
              <>
                <Hero />
                <Events />
                <Categories />
                <Newsletter />
              </>
            } />
          </Routes>
        </main>
        <Footer />
        <PurchaseModal />
      </div>
    </AppProvider>
  );
}

export default App;
