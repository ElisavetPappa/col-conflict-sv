library(dplyr)
library(haven)
library(tidyr)
library(jtools)
library(table1)
library(gtsummary)
library(fastDummies)
library(stringr)

# set working directory 
setwd("S:/PAPSIVI_Data/PAPSIVI/paper3/")
output_dir <- "S:/PAPSIVI_Data/PAPSIVI/paper3/output/"

#
# Function to read in data files
#

read_in_minsalud_file <- function(filename) {
  # Read in datafile
  flat_df <- read.csv(filename, header = TRUE, sep = '|', stringsAsFactors = TRUE, encoding = "UTF-8")
  
  # Rename miscoded PersonaID variable label
  flat_df <- flat_df %>%
    rename(personid = X.U.FEFF.PersonaID)
  
  # Convert all the variable names to lowercase
  names(flat_df) <- tolower(names(flat_df))
  
  return(flat_df)
}

#
# Read in and recode register of Victims files
#

ruv_filename = "S:/PAPSIVI_Data/data_files/ExtraccionRUV20211201.txt"
ruv_df <- read_in_minsalud_file(ruv_filename)

# Remove last row (it's empty)
ruv_df <- ruv_df |>
  filter(row_number() <= n() -1)

# Remove ZonaResidencia variable (has 'SIN INFORMACION' for everything)
ruv_df$zonaresidencia <- NULL

# Extract the municipio code from the mpioresidencia and put it into a separate variable municipio_id
ruv_df <- ruv_df |>
  mutate(municipio_id = str_split(mpioresidencia, " - ", simplify = TRUE)[,1])

# Recode armed conflict exposure events
ruv_df <- ruv_df |>
  mutate(hechovictimizante = case_match(hechovictimizante,
                                        "ABANDONO O DESPOJO FORZADO DE TIERRAS" ~ "despojo_tierras",
                                        "ACTO TERRORISTA / ATENTADOS / COMBATES / ENFRENTAMIENTOS / HOSTIGAMIENTOS" ~ "hostigamientos",
                                        "AMENAZA" ~ "amenaza",
                                        "CONFIMANIENTO" ~ "confinamiento",
                                        "DELITOS CONTRA LA LIBERTAD Y LA INTEGRIDAD SEXUAL EN DESARROLLO DEL CONFLICTO ARMADO" ~ "violenciasexual",
                                        "DESAPARICIÓN FORZADA" ~ "desaparacion",
                                        "DESPLAZAMIENTO FORZADO" ~ "desplazamiento",
                                        "HOMICIDIO" ~ "homicidio",
                                        "LESIONES PERSONALES FISICAS" ~ "lesion_fis",
                                        "LESIONES PERSONALES PSICOLOGICAS" ~ "lesion_psic",
                                        "MINAS ANTIPERSONAL, MUNICIÓN SIN EXPLOTAR Y ARTEFACTO EXPLOSIVO IMPROVISADO" ~ "minas",
                                        "PERDIDA DE BIENES MUEBLES O INMUEBLES" ~ "perdida_bienes",
                                        "SECUESTRO" ~ "secuestro",
                                        "TORTURA" ~ "tortura",
                                        "VINCULACIÓN DE NIÑOS NIÑAS Y ADOLESCENTES A ACTIVIDADES RELACIONADAS CON GRUPOS ARMADOS" ~ "reclut_ninos",
                                        "SIN INFORMACIÓN" ~ "no_info"))

# Recode anyone 'older' than 110 to missing
ruv_df <- ruv_df %>%
  mutate(edad = ifelse(edad > 110, NA, edad)) %>%
  mutate(edad = ifelse(edad == 0, NA, edad))

# Add age group ranges
ruv_df <- ruv_df %>%
  mutate (age_group = case_when(
    edad >= 0 & edad <= 5 ~"0-5",
    edad >= 6 & edad <= 11 ~"6-11",
    edad >= 12 & edad <= 17 ~"12-17",
    edad >= 18 & edad <= 28 ~"18-28",
    edad >= 29 & edad <= 59 ~"29-59",
    edad >= 60 ~"60+",
    TRUE ~ NA_character_
  ))

ruv_df$age_group <- factor(ruv_df$age_group,
                           levels = c("0-5", "6-11", "12-17", "18-28", "29-59","60+"),
                           ordered = TRUE)

# Recode sex
ruv_df <- ruv_df |>
  mutate(sexo = case_match(sexo,
                           "HOMBRE" ~ "Male",
                           "MUJER" ~ "Female",
                           "LGBTI" ~ "Other",
                           "NO DEFINIDO" ~ NA))

ruv_df$sexo <- factor(ruv_df$sexo, ordered = FALSE)
ruv_df$sexo <- relevel(ruv_df$sexo, ref = "Male")

# Recode ethnicity
ruv_df <- ruv_df |>
  mutate(etnia = case_match(etnia,
                            "1 - INDÍGENA" ~ "Indigenous",
                            "2 - ROM (GITANO)" ~ "Roma",
                            "3 - RAIZAL (SAN ANDRES Y PROVIDENCIA)" ~ "Raizal",
                            "4 - PALENQUERO DE SAN BASILIO" ~ "Palenquero de San Basilio",
                            "5 - NEGRO, MULATO, AFROCOLOMBIANO O AFRODESCENCIENTE" ~ "Afrocolombian",
                            "NO DEFINIDO" ~ "White or Mestiza"))
ruv_df$etnia <- as.factor(ruv_df$etnia)

# Create ethnic minority variable
ruv_df <- ruv_df |>
  mutate(etnia_min = ifelse(etnia == "White or Mestiza", "No", "Yes"))

ruv_df$etnia_min <- factor(ruv_df$etnia_min, ordered = FALSE)
ruv_df$etnia_min <- relevel(ruv_df$etnia_min, ref = "No")

# Recode indicador PAPSIVI to from YES / NO to 1 / 0 and label
ruv_df <- ruv_df |>
  mutate(indicadorpapsivi = ifelse(indicadorpapsivi == "NO", 0, 1))

ruv_df$indicadorpapsivi <- factor(ruv_df$indicadorpapsivi,
                                  levels = c(0, 1),
                                  labels = c("No", "Yes"))

# Recode indicador Discapacidad to from YES / NO to 1 / 0 and label
ruv_df <- ruv_df |>
  mutate(indicadordiscapacidad = ifelse(indicadordiscapacidad == "NO", 0, 1))

ruv_df$indicadordiscapacidad <- factor(ruv_df$indicadordiscapacidad,
                                       levels = c(0, 1),
                                       labels = c("No", "Yes"))

# Make copy 
df <- ruv_df


##################################################################
#
# Descriptives of victims
#
##################################################################

sexual_violence_allreg <- subset(df, hechovictimizante == "violenciasexual")

label(sexual_violence_allreg$sexo) <- "Sex"
label(sexual_violence_allreg$edad) <- "Age"
label(sexual_violence_allreg$age_group) <- "Age group"
label(sexual_violence_allreg$etnia) <- "Ethnicity"

# Generate descriptive statistics tables and write to file
table1(~ sexo + etnia + age_group + edad, data = sexual_violence_allreg)
descrip_table <- table1(~ sexo + etnia + age_group + edad, data = sexual_violence_allreg)
write(descrip_table, file = paste(output_dir, "descrip_table_multireg.html", sep = ""))


##################################################################
#
# Generate N sexual violence victims by municipio and write to file
#
##################################################################

municipio_sv_table <- sexual_violence_allreg %>%
  group_by(municipio_id) %>%
  summarise(
    mpioresidencia = first(mpioresidencia),
    N = n_distinct(personid)
  ) %>%
  ungroup()

write.csv(municipio_sv_table, file = paste(output_dir, "sv_by_municipio.csv", sep = ""), row.names = FALSE)


##################################################################
#
# Calculate how frequently non-sexual violence victimisation occurs
# with sexual violence
#
##################################################################

# Identify persons who experienced sexual violence
sv_victims <- df %>%
  filter(hechovictimizante == "violenciasexual") %>%
  distinct(personid) %>%
  pull(personid)

# Calculate co-occurrence for each armed conflict event type
cooccurrence_table <- df %>%
  filter(hechovictimizante != "violenciasexual") %>%
  group_by(hechovictimizante) %>%
  summarise(
    N = n_distinct(personid),
    N_cooccurrence_with_SV = n_distinct(personid[personid %in% sv_victims]),
    .groups = 'drop'
  ) %>%
  mutate(
    Percentage = round((N_cooccurrence_with_SV / N) * 100, 2)
  ) %>%
  rename(
    `Armed conflict exposure event` = hechovictimizante,
    `N Co-occurrence with sexual violence` = N_cooccurrence_with_SV,
    `%` = Percentage
  ) %>%
  arrange(desc(`%`))

# Display the table
print(cooccurrence_table)

# Write to file
write.csv(cooccurrence_table, file = paste(output_dir, "sv_cooccurrence_table.csv", sep = ""), row.names = FALSE)

