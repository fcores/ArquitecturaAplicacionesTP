
import React, { useState, useEffect } from 'react';

function Health() {
    const [data, setData] = useState('Cargando...');

    useEffect(() => {
        const fetchHealth = async () => {
            try {
                const apiUrl = (process.env.REACT_APP_API_URL  + "/health") || 'http://localhost:8000/health';
                const response = await fetch(apiUrl);
                const result = await response.json();
                setData(JSON.stringify(result, null, 2));
            } catch (error) {
                setData(`Error: ${error.message}`);
            }
        };

        fetchHealth();
    }, []);

    return (
        <h1>{data}</h1>
    );
}

export default Health;