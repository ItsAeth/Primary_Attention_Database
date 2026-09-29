# Base de Datos para Atención Primaria

## Sobre el proyecto

Este proyecto consiste en una base de datos relacional para representar diferentes aspectos de la actividad asistencial y de la información clínica asociada a pacientes en un centro de atención primaria. El modelo permite gestionar información de pacientes y personal, actividad asistencia e historia clínica asegurando la integridad de los datos y la relación entre los registros.

Este proyecto me ha permitido explorar las necesidades de almacenamiento de información de un centro de información, así como los terminología y codificación utilizados en el ámbito sanitario con el objetivo de aportar mayor realismo.

La información  referente al esquema actual se encuentra en `docs/about_schema.md`.

El esquema relacional actualmente no cuenta con todas las tablas necesarias para cubrir el [conjunto mínimo de datos](https://www.boe.es/eli/es/rd/2010/09/03/1093/con) de informes de atención primaria e historia clínica electronica, y sera expandido en un futuro.

El proyecto utiliza datos completamente sintéticos.

<img src="docs/schema.png">

## Requerimientos

- PostgreSQL v18.

## Instalación

1. Clonar el repositorio.

```bash
git clone https://github.com/ItsAeth/Primary_Healthcare_DB.git
cd Primary_Healthcare_DB
```

2. Crear una nueva base de datos y realizada la conexión a esta.
3. Ejecutar los scripts SQL del repositorio en el orden indicado. Los scripts se encuentran en la carpeta `database/`.

## Uso

La base de datos puede utilizarse para realizar consultas SQL sobre la información de pacientes, personal, actividad asistencial e historia clínica.

## Fuentes y referencias

El diseño se ha basado parcialmente en normativa y documentación sanitaria pública, incluyendo:

- [BOE](https://www.boe.es/eli/es/rd/2010/09/03/1093/con): normativa relacionada con la historia clínica y la información sanitaria.
- SNOMED CT: terminología clínica.
- CIE: clasificación de enfermedades.
- EMDN: nomenclatura europea de productos sanitarios.
- eHDSI: terminologías utilizadas para el intercambio de información sanitaria.