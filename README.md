# Trabajo practico 2 - Analisis Inteligente de Datos. 
## Maestria en Ciancia de Datos. Universidad Austral. 
 

### Descripción del trabajo. 

Este repositorio contiene una aplicación web interactiva desarrollada con Quarto y Shiny, diseñada para visualizar indicadores básicos proporcionados por la Organización Panamericana de la Salud (OPS). La aplicación permite explorar de manera dinámica diversos indicadores de salud de los países de América.


### Datos: 
Los datos fueron extraídos de la Organización Panamericana de la Salud/Organización Mundial de la Salud. Portal de Indicadores Básicos. Región de las Américas. Washington D.C. [Consultado: FECHA]. Disponible en: https://opendata.paho.org/es/indicadores-basicos


### Estructura del repositorio

La estructura de archivos en el repositorio es la siguiente:

```plaintext
/tarea2-bnrey/
├── /datos_curados/                        # Carpeta con los datos originales sin procesar
│    ├── indicadores_curados.csv           # Datos curados. No se pudo cargar el dataset original
├── /script de limpieza                    # Carpeta que alberga el script de limpieza
      ├── script_limpieza.R                # script para poder curar los datos a utilizar  
├── .gitignore                             # Archivos que Git ignorará
├── README.md                              # Documentación del proyecto
├── enunciado.md                           # Explicación de la tarea
├── index.qmd                              # Documento quarto interactivo
 
```

### Requisitos

Para ejecutar la aplicación de manera local, se necesita:
	•	R (≥ 4.1)
	•	RStudio

**Paquetes requeridos en R**:
- shiny
- ggplot2
- plotly
- dplyr
- readr
- knitr


### Intrucciones de instalacion: 
1) Clona el repositorio:

  ``` bash: 
git clone https://github.com/tu-usuario/dashboard-ops-indicadores.git
  ```
2) Instala los paquetes requeridos en R:

``` R:
install.packages(c("shiny", "quarto", "ggplot2", "plotly", "dplyr", "sf", "readr"))
```
3) Abre el archivo Quarto (dashboard.qmd) en RStudio.

4) Ejecuta la aplicación:
- Haz clic en el botón Ejecutar Documento en RStudio, o
- Usa el terminal:

``` bash:
quarto preview dashboard.qmd
```

### Uso

1) Inicia la aplicación.
2)  Selecciona un indicador y un año desde los menús desplegables.
3) Explora el gráfico de barras interactivo, pasando el cursor sobre las barras para ver detalles y tendencias a lo largo del tiempo.

### Contribuciones

¡Las contribuciones para mejorar este proyecto son bienvenidas! 


