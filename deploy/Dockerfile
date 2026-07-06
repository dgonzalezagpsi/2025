# Dockerfile para Shiny App - Salud Mental Dashboard
# Base image con R y Shiny preinstalado
FROM rocker/shiny:4.2.0

# Instalar dependencias del sistema
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev \
    libssl-dev \
    libxml2-dev \
    libpng-dev \
    libjpeg-dev \
    && apt-get clean

# Instalar paquetes R necesarios
RUN R -e "install.packages(c( \
    'shiny', \
    'shinydashboard', \
    'ggplot2', \
    'dplyr', \
    'plotly', \
    'haven', \
    'DT', \
    'corrplot', \
    'tidyr', \
    'scales', \
    'magrittr' \
))"

# Copiar archivos de la app
COPY app.R /srv/shiny-server/
COPY basedigi2025.sav /srv/shiny-server/
COPY basedigi2025_clean.csv /srv/shiny-server/

# Cambiar permisos
RUN chown -R shiny:shiny /srv/shiny-server

# Exponer puerto
EXPOSE 3838

# Comando para ejecutar
CMD ["/usr/bin/shiny-server.sh"]
