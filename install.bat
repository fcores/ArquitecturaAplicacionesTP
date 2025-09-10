@echo off
echo ========================================
echo    TicketPardo - Instalacion Completa
echo ========================================
echo.
echo Instalando dependencias del proyecto...
echo.

echo [1/2] Instalando dependencias de Node.js...
npm install

echo.
echo [2/2] Instalando dependencias de Python...
pip install -r requirements.txt

echo.
echo ========================================
echo    Instalacion completada!
echo ========================================
echo.
echo Para iniciar el proyecto:
echo npm run dev
echo.
echo Esto iniciara tanto el backend como el frontend
echo Backend: http://localhost:8000
echo Frontend: http://localhost:3000
echo.
echo ========================================
pause
