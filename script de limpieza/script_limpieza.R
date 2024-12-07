library(readr)
library(dplyr)

# Dado que el espacio de carga en github es limitado, he realizado la limpieza 
# de datos en este script y guardado el archivo de datos limpio en la carpeta datos
# de este repositorio. En realidad la unica reduccion que he hecho es quedarme con las 
# variables que voy a usar. 
# Para acceder a los datos crudos, se puede ir al sitio web de la PAHO, el link 
# se puede encontrar en el README del repositorio. 

data <- read_csv("../datos_crudos/Indicadores_PAHO.csv", 
                          show_col_types = FALSE)

# Nos quedamos con las variables de interes

data <- data %>%
  select(c(paho_indicator_id, nombre_indicador, spatial_dim, 
           spatial_dim_es, time_dim_type, time_dim, numeric_value)) %>%
  filter(time_dim <= 2024 & time_dim >= 1995)

# Guardamos los datos limpios

write_csv(data, "../datos_curados/indicadores_curados.csv")


