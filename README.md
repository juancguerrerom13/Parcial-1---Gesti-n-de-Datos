# Parcial final · Gestión de Datos · Parte 2 (práctica) - Juan Camilo Guerrero Martínez

Pontificia Universidad Javeriana — Maestría en Analítica e Inteligencia de Negocios.
Análisis, limpieza y construcción de una vista minable sobre `ConsumerComplaints_taller.csv` para predecir `Consumer Disputed` (Yes/No).

> **El desarrollo completo del parcial está en el notebook [`work/Parcial_Parte2_Plantilla_Vfinal.ipynb`](work/Parcial_Parte2_Plantilla_Vfinal.ipynb):** cada punto tiene su código ejecutado con las salidas guardadas, y su análisis, interpretación y justificación en las celdas markdown correspondientes. Este README solo describe el repositorio, cómo ejecutar el entorno y un resumen de resultados.

El enunciado está escrito para Kiro, pero el parcial se desarrolla con **Claude Code** (Anthropic). Por eso las reglas que el punto 1.1 pide en `.kiro/steering/parcial.md` están en `.claude/CLAUDE.md`, que es el archivo de instrucciones persistentes equivalente en Claude Code.

## Estructura

```
.
├── .claude/CLAUDE.md          # Contexto y reglas del agente (equivale al steering del punto 1.1)
├── BITACORA.md                # Bitácora agéntica (prompts, modelo, consumo)
├── README.md
├── Dockerfile                 # Imagen basada en quay.io/jupyter/scipy-notebook
├── docker-compose.yml         # Servicio Jupyter Lab con ./work montado
├── requirements.txt           # Dependencias del entorno (incluye ydata-profiling)
├── .dockerignore / .gitignore
└── work/                      # = /home/jovyan/work en el contenedor
    ├── Parcial_Parte2_Plantilla_Vfinal.ipynb
    └── data/
        ├── ConsumerComplaints_taller.csv   # Datos originales
        └── vista_minable_parcial.csv       # Vista minable exportada en el punto 6
```

## Cómo ejecutar el entorno

Requisito: Docker Desktop encendido.

```bash
docker compose up -d --build
```

Abrir <http://127.0.0.1:8888/lab> y ejecutar `Parcial_Parte2_Plantilla_Vfinal.ipynb` completo y en orden (*Run → Run All Cells*): cada sección usa variables de las anteriores (`perfil`, `df_limpio`, `vista`). Desde el notebook los datos se leen con la ruta relativa `data/ConsumerComplaints_taller.csv`.

También se puede ejecutar de principio a fin sin abrir el navegador, guardando las salidas en el mismo archivo:

```bash
docker exec parcial-gestion-datos jupyter nbconvert --to notebook --execute --inplace Parcial_Parte2_Plantilla_Vfinal.ipynb
```

Los procesos aleatorios (partición train/test y sobremuestreo) usan `random_state=42`, así que los resultados se reproducen igual en cada ejecución.

Detener el entorno:

```bash
docker compose down
```

El servidor solo escucha en `127.0.0.1` (sin token), así que no queda expuesto a la red. Todos los cambios hechos en el contenedor dentro de `work/` se guardan directamente en la carpeta del host.

## Contenido del parcial

Resumen de lo desarrollado en el notebook. Todas las cifras provienen de sus salidas ejecutadas; el análisis y las justificaciones completas de cada punto están en las celdas markdown del notebook.

| Punto | Qué se hizo | Resultado |
|---|---|---|
| 1. Proyecto y carga | Reglas del agente en `.claude/CLAUDE.md`; carga del CSV y renombre de la columna sin encabezado a `ID` | (2018, 19) |
| 2. Perfilado | Tabla de las 19 columnas: almacenamiento, tipo conceptual, nulos y valores distintos | Almacenamiento: 13 categóricas / 6 numéricas. Conceptual: 12 nominales, 3 continuas, 2 fechas, 2 identificadores. 5 columnas con tipo mal almacenado |
| 3. Estadística descriptiva | Cuartiles, IQR, media, mediana, sesgo y curtosis de Fisher; histogramas con KDE y boxplot por `Product Name` | `Consumer Complaint Narrative` y `Company Public Response` muy asimétricas y con colas pesadas; `Consumer Consent Provided` casi uniforme |
| 4.1 Atributos sin valor | Identificadores, columnas con > 80 % de nulos y duplicados | Se eliminan `ID`, `Complaint ID` y `Tags`; 0 duplicados → (2018, 16) |
| 4.2 Faltantes | Mecanismo por cruce con otras variables (chi-cuadrado) | `Sub Product` / `Sub Issue`: "No aplica"; `State Name` / `Zip Code` y `Consumer Disputed`: se eliminan filas → (1989, 16) |
| 4.3 Inconsistencias | Fechas a `datetime`; regla envío ≥ recepción | 42 casos (todos −1 día, canal Web) corregidos; 0 inconsistencias |
| 4.4 Atípicos | Límites de Tukey y winsorización | 93 y 104 atípicos recortados; curtosis 8.24 → 0.22 y 4.39 → 0.23 |
| 4.5 Redundancia | Correlación de Pearson y Spearman; relación `Zip Code` → `State Name` | Sin redundancia numérica; `Zip Code` redundante con `State Name` |
| 5.1 Normalización | Logaritmo (`Consumer Complaint Narrative`) y escalamiento robusto (`Company Public Response`) | Sesgo 1.08 → 0.28 con el logaritmo; mediana 0 e IQR 1 con el escalamiento robusto |
| 5.2 Discretización | `Consumer Consent Provided` en 13 bins (Freedman-Diaconis) | Variable ordinal 0–12 |
| 5.3 Numerización | One-Hot (3 variables), frequency encoding (`Company` y otras 4), `Dias Envio` a partir de las fechas | (1989, 27), todo numérico, 0 nulos |
| 5.4 Objetivo y balanceo | Objetivo 0/1, partición 80/20 estratificada, sobremuestreo aleatorio solo del train | Train 358 → 1233 casos *Yes* (50/50); test intacto (309 / 89) |
| 6. Entrega | Exportación de la vista minable completa | `work/data/vista_minable_parcial.csv`, (1989, 27) |

Librerías usadas: pandas, numpy, scipy, matplotlib, seaborn y scikit-learn (incluidas en la imagen base). El balanceo se hizo con `sklearn.utils.resample`, sin instalar librerías adicionales.
