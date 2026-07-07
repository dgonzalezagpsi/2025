# Guía Completa: Subir a GitHub y Desplegar

## ✅ Paso 1: Preparar el Proyecto Localmente

### 1.1 Inicializar Git
```bash
cd C:\Users\dna64\OneDrive\Documentos\Claude\Projects\2022
git init
git config user.name "Tu Nombre"
git config user.email "tu-email@gmail.com"
```

### 1.2 Crear Archivo .gitignore
```bash
# Ya creado en el proyecto
```

### 1.3 Hacer el Primer Commit
```bash
git add .
git commit -m "Inicial: Dashboard Shiny de Salud Mental"
```

---

## ✅ Paso 2: Crear Repositorio en GitHub

### 2.1 Crear Repositorio
1. Ir a [github.com](https://github.com)
2. Click en "+" → "New repository"
3. Nombre: `powerbi-salud-mental`
4. Descripción: "Dashboard interactivo de salud mental para profesionales de la salud"
5. Seleccionar "Public" (público) o "Private" (privado)
6. Click "Create repository"

### 2.2 Conectar Repositorio Local con GitHub
```bash
git remote add origin https://github.com/TU-USUARIO/powerbi-salud-mental.git
git branch -M main
git push -u origin main
```

---

## ✅ Paso 3: Desplegar en la Nube

### OPCIÓN A: Shiny.io (Más Fácil - Recomendado ⭐)

#### 3A.1 Crear Cuenta
1. Ir a [shinyapps.io](https://www.shinyapps.io)
2. Sign up con tu cuenta de RStudio o GitHub
3. Copiar el token de autenticación

#### 3A.2 Conectar en RStudio
```r
# Instalar rsconnect
install.packages("rsconnect")

# Configurar cuenta
rsconnect::setAccountInfo(
  name = "tu-usuario",
  token = "tu-token-aqui",
  secret = "tu-secret-aqui"
)

# Desplegar
rsconnect::deployApp('app.R')
```

#### 3A.3 Resultado
Tu app estará en: `https://tu-usuario.shinyapps.io/powerbi-salud-mental`

---

### OPCIÓN B: Heroku (Gratis con Limitaciones)

#### 3B.1 Instalar Heroku CLI
```bash
# Windows: Descargar desde https://devcenter.heroku.com/articles/heroku-cli
# Después de instalar:
heroku login
```

#### 3B.2 Crear App en Heroku
```bash
heroku create powerbi-salud-mental
```

#### 3B.3 Crear Dockerfile
```bash
# Ya puedes usar el que te proporcioné o crear uno nuevo
```

#### 3B.4 Desplegar
```bash
git push heroku main
```

#### 3B.5 Resultado
Tu app estará en: `https://powerbi-salud-mental.herokuapp.com`

---

### OPCIÓN C: Railway (Fácil y Moderno ⭐⭐)

#### 3C.1 Crear Cuenta
1. Ir a [railway.app](https://railway.app)
2. Sign up con GitHub
3. Conectar tu repositorio

#### 3C.2 Configurar Railway
1. Click "New Project" → "Deploy from GitHub"
2. Seleccionar tu repositorio `powerbi-salud-mental`
3. Railway detecta automáticamente que es R/Shiny
4. Click "Deploy"

#### 3C.3 Resultado
Tu app estará en: `https://powerbi-salud-mental.up.railway.app`

---

### OPCIÓN D: Google Cloud / AWS (Profesional)

#### Google Cloud Run
```bash
# 1. Crear Dockerfile (proporcionado)
# 2. Compilar imagen
docker build -t powerbi-salud-mental .

# 3. Subir a Google Cloud
gcloud run deploy powerbi-salud-mental \
  --source . \
  --platform managed \
  --region us-central1
```

---

## ✅ Paso 4: Integración Continua (CI/CD)

### 4.1 GitHub Actions (Despliegue Automático)

Crear archivo `.github/workflows/deploy.yml`:

```yaml
name: Deploy to Shinyapps

on:
  push:
    branches: [ main ]

jobs:
  deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v2
    
    - name: Setup R
      uses: r-lib/actions/setup-r@v2
    
    - name: Install dependencies
      run: |
        Rscript -e "install.packages(c('shiny', 'shinydashboard', 'ggplot2', 'dplyr', 'plotly', 'haven', 'DT', 'corrplot', 'rsconnect'))"
    
    - name: Deploy to Shinyapps
      env:
        SHINYAPPS_ACCOUNT: ${{ secrets.SHINYAPPS_ACCOUNT }}
        SHINYAPPS_TOKEN: ${{ secrets.SHINYAPPS_TOKEN }}
        SHINYAPPS_SECRET: ${{ secrets.SHINYAPPS_SECRET }}
      run: |
        Rscript -e "
        rsconnect::setAccountInfo(name='${{ secrets.SHINYAPPS_ACCOUNT }}', token='${{ secrets.SHINYAPPS_TOKEN }}', secret='${{ secrets.SHINYAPPS_SECRET }}')
        rsconnect::deployApp('app.R')
        "
```

### 4.2 Configurar Secrets en GitHub
1. Ir a tu repositorio en GitHub
2. Settings → Secrets → New repository secret
3. Agregar:
   - `SHINYAPPS_ACCOUNT`
   - `SHINYAPPS_TOKEN`
   - `SHINYAPPS_SECRET`

---

## ✅ Paso 5: Actualizar Datos desde Qualtrics (Opcional)

### 5.1 Integración con API de Qualtrics
```r
# Instalar librería
install.packages("qualtRics")

# En app.R, agregar:
library(qualtRics)

# Cargar datos automáticamente
df <- fetch_survey(
  surveyID = "SV_tu_survey_id",
  label = FALSE,
  convert = FALSE,
  force_request = TRUE
)
```

### 5.2 Scheduler (Actualizar Diariamente)
```r
library(cronR)

# Programar actualización diaria a las 2:00 AM
cron_add(
  command = "Rscript update_data.R",
  frequency = "daily",
  at = "2:00 AM"
)
```

---

## ✅ Paso 6: Validar Despliegue

### Checklist Final
- ✅ App funciona localmente (`shiny::runApp()`)
- ✅ Código está en GitHub
- ✅ README.md está actualizado
- ✅ Datos están en formato correcto (.sav o .csv)
- ✅ Todas las librerías están en requirements.txt
- ✅ App está desplegada y accesible en URL pública
- ✅ Filtros funcionan correctamente
- ✅ Gráficos se cargan sin errores

---

## 🔗 URLs Útiles

| Plataforma | URL | Costo |
|-----------|-----|-------|
| **Shiny.io** | [shinyapps.io](https://www.shinyapps.io) | Gratis (25 horas/mes) |
| **Railway** | [railway.app](https://railway.app) | $5-20/mes |
| **Heroku** | [heroku.com](https://www.heroku.com) | Gratis (limitado) |
| **Google Cloud** | [cloud.google.com](https://cloud.google.com) | Pay-as-you-go |
| **GitHub** | [github.com](https://github.com) | Gratis |

---

## 🚀 Próximos Pasos

1. **Compartir URL:** Tu app estará en `https://tu-usuario.shinyapps.io/powerbi-salud-mental`
2. **Documentación:** Mantener README.md actualizado
3. **Usuarios:** Compartir acceso con colegas/institución
4. **Mejoras:** Agregar más análisis según feedback
5. **Datos:** Actualizar con nuevos registros cuando sea necesario

---

## ❓ Troubleshooting

### Error: "Package not found"
```r
install.packages("nombre_paquete")
```

### Error: "Port already in use"
```bash
# Buscar proceso en puerto 3838
lsof -i :3838
# Matar proceso
kill -9 <PID>
```

### Error: "Datos no se cargan"
- Verificar que `basedigi2025.sav` esté en el mismo directorio que `app.R`
- Verificar que la ruta sea relativa, no absoluta

### Error: "Shinyapps.io no despliega"
```r
# Revisar logs
rsconnect::showLogs()
```

---

## 📞 Soporte

- **Documentación Shiny:** [shiny.rstudio.com](https://shiny.rstudio.com)
- **GitHub Docs:** [docs.github.com](https://docs.github.com)
- **Stack Overflow:** Tag `r` y `shiny`
- **Community:** [RStudio Community](https://community.rstudio.com)

---

**Última actualización:** Julio 5, 2025
