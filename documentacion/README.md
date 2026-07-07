# Dashboard Interactivo en R Shiny

Dashboard profesional para análisis de salud mental en profesionales de la salud, construido con **R Shiny**.

## Características

- **Filtros Dinámicos** 
- **KPIs en Tiempo Real** que se actualizan según filtros:


- **Pestañas de Análisis:**
  1. **Dashboard** - KPIs y gráficos principales
  2. **Análisis Profundo** - Burnout, fatiga, satisfacción
  3. **Correlaciones** - Matrices y scatter plots
  4. **Datos** - Tabla interactiva con 581 registros
  5. **Información** - Metadata del estudio

- **Visualizaciones Interactivas:**
  - 
## Datos

- **Muestra:** 581 profesionales de la salud
- **Variables:** 35+ indicadores de salud mental
- **Instrumentos:** CD-RISC, MHC-SF, ProQol, PHQ-9, GAD-7
- **Período:** Abril - Agosto 2025

## 🚀 Instalación Local

### Requisitos
- R >= 4.0
- RStudio (recomendado)

### Pasos

1. **Clonar el repositorio:**
```bash
git clone https://github.com/dgonzalezagpsi/2025.git
cd powerbi-salud-mental
```

2. **Instalar dependencias:**
```r
install.packages(c(
  "shiny",
  "shinydashboard",
  "ggplot2",
  "dplyr",
  "plotly",
  "haven",
  "DT",
  "corrplot"
))
```

3. **Ejecutar la aplicación:**
```r
shiny::runApp()
```

4. **Acceder a la app:**
La aplicación se abrirá en `http://localhost:3838`

## Desplegar en la Nube

### Opción 1: Shiny Server (Servidor Propio)

```bash
# Instalar Shiny Server en Linux
sudo apt-get install r-base
sudo wget https://download3.rstudio.org/ubuntu-14.04/x86_64/shiny-server-1.5.20.973-amd64.deb
sudo gdebi shiny-server-1.5.20.973-amd64.deb

# Copiar app a /srv/shiny-server/
sudo cp -r powerbi-salud-mental /srv/shiny-server/
```

Acceder en: `http://tu-servidor:3838/powerbi-salud-mental`

### Opción 2: Shiny Cloud (RStudio)

1. Crear cuenta en [shinyapps.io](https://www.shinyapps.io)
2. Instalar el paquete `rsconnect`:
```r
install.packages("rsconnect")
rsconnect::setAccountInfo(name='tu-cuenta', token='...', secret='...')
```

3. Desplegar:
```r
rsconnect::deployApp('app.R')
```

### Opción 3: Heroku + Docker

1. Crear `Dockerfile`:
```dockerfile
FROM rocker/shiny:latest
RUN apt-get update && apt-get install -y \
    libcurl4-gnutls-dev libssl-dev libxml2-dev
RUN R -e "install.packages(c('shiny', 'shinydashboard', 'ggplot2', 'dplyr', 'plotly', 'haven', 'DT', 'corrplot'))"
COPY app.R /srv/shiny-server/
EXPOSE 3838
CMD ["/usr/bin/shiny-server.sh"]
```

2. Desplegar:
```bash
git push heroku main
```

### Opción 4: GitHub Pages + HTML (Alternativa)

Convertir Shiny a HTML estático:
```r
# Exportar gráficos como HTML
htmlwidgets::saveWidget(plotly_object, "chart.html")
```

## Estructura del Proyecto

```
powerbi-salud-mental/
├── app.R                      # Aplicación Shiny principal
├── basedigi2025.sav          # Datos en formato SPSS
├── basedigi2025_clean.csv    # Datos limpios en CSV
├── requirements.txt          # Dependencias Python (opcional)
├── renv.lock                 # Snapshot de dependencias R
├── Dockerfile                # Configuración Docker
├── .github/
│   └── workflows/
│       └── deploy.yml        # CI/CD con GitHub Actions
├── README.md                 # Este archivo
├── LICENSE                   # Licencia del proyecto
└── docs/
    ├── MANUAL.md            # Manual de uso
    ├── METODOLOGIA.md       # Metodología de investigación
    └── VARIABLES.md         # Diccionario de variables
```

## Integración con Qualtrics

Para integrar con Qualtrics:

1. **Exportar datos de Qualtrics:**
   - Qualtrics → Data & Analysis → Export Data
   - Seleccionar formato SPSS (.sav)
   - Guardar como `basedigi2025.sav`

2. **Actualizar datos automáticamente (via API):**
```r
# En app.R, agregar:
library(qualtRics)

# Cargar datos de Qualtrics
data <- fetch_survey(surveyID = "SV_xxxx")
df_clean <- data %>% process_data()
```

3. **Programar actualización diaria:**
```r
# Usar un cron job o GitHub Actions
schedule::run_every(1, unit = "day", run_data())
```

## Seguridad

- Datos anonimizados (sin identificadores personales)
- Consentimiento informado requerido
- Cumplimiento GDPR/LOPD
- Acceso restringido si es necesario

## Análisis Incluidos

### Correlaciones
- Matriz de correlaciones
- Scatter plots (Resiliencia vs Bienestar, Edad vs Resiliencia)
- Análisis de asociaciones

## Casos de Uso

✓ Investigación académica
✓ Evaluación institucional
✓ Monitoreo de salud mental ocupacional
✓ Diseño de intervenciones
✓ Comunicación con stakeholders
✓ Benchmarking con otras organizaciones

## Instrucciones de Uso

### Aplicar Filtros
1. En la barra lateral izquierda, seleccionar valores en los filtros
2. Los gráficos y KPIs se actualizan automáticamente
3. Hacer clic en "Restablecer Filtros" para limpiar

### Navegar Pestañas
- **Dashboard:** Visión general rápida
- **Análisis Profundo:** Indicadores específicos de salud mental
- **Correlaciones:** Relaciones entre variables
- **Datos:** Acceso a registros individuales
- **Información:** Documentación y metodología

### Exportar Datos
- Tablas: Hacer clic en botón "Download" en la tabla
- Gráficos: Usar opciones de Plotly (camera icon)

## 📚 Referencias

- [CD-RISC Escala de Resiliencia](https://academic.oup.com/depress-anxiety/article/13/2/78/6247)
- [MHC-SF Continuo de Salud Mental](https://www.tandfonline.com/doi/full/10.1080/10439463.2011.546888)
- [ProQol Calidad de Vida Profesional](https://proqol.org/)

## 👥 Autores

- **Investigación:** Donald Wylman González Aguilar
- **Desarrollo:** Claude AI + R Shiny
- **Datos:** Indicadores de salud mental en universitarios que desarrollan trabajo con personas en el departamento de Guatemala. Esta investigación fue cofinanciada con recursos de la Escuela de Ciencias Psicologicas y del Fondo de Investigación de la DIGI de la Universidad de San Carlos de Guatemala a través de la partida presupuestaria número: 4.8.63.0.84 en el Programa Universitario de Investigación en Educación.

## 📜 Licencia

MIT License - Ver `LICENSE.md` para detalles

## 🤝 Contribuir

Las contribuciones son bienvenidas:

1. Fork el repositorio
2. Crear una rama (`git checkout -b feature/mejora`)
3. Commit cambios (`git commit -am 'Agregar mejora'`)
4. Push a la rama (`git push origin feature/mejora`)
5. Abrir Pull Request

## 📧 Contacto

Para preguntas o sugerencias:
- Email: tu-email@institucion.edu
- Issues: [GitHub Issues](https://github.com/tu-usuario/powerbi-salud-mental/issues)

## 🔄 Versiones

- **v1.0** (Julio 2026) - Versión inicial
  - Dashboard interactivo completo
  - 5 pestañas de análisis
  - 4 filtros dinámicos
  - 581 registros procesados

---

**Última actualización:** Julio 5, 2026
