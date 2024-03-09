#!/bin/bash

#--------------------------------------------------------------
#Version 1: mafft with standard parameters
#Version 2: nombre de output con fasta
#--------------------------------------------------------------


# Ruta de la carpeta con los archivos
carpeta="/ruta/a/tu/carpeta"

# Crear una carpeta para los archivos alineados
carpeta_alineados="$carpeta/alineados"
mkdir -p "$carpeta_alineados"

# Contador de archivos alineados
alineados=0

#Ejecución de conda
conda activate
conda activate mafft

# Contador de archivos totales
total_archivos=$(find "$carpeta" -type f | wc -l)

# Itera sobre cada archivo en la carpeta
for archivo in "$carpeta"/*; do
    if [[ -f "$archivo" ]]; then
        # Ejecuta el alineamiento con MAFFT (ajusta los parámetros según tus necesidades)
        # Se ejecutará sin parámetros, pero puede que sirva el método L-INS-i por la cantidad de secuencias
        mafft "$archivo" > "${archivo}.fa"
        alineados=$((alineados + 1))
        archivos_faltantes=$((total_archivos - alineados))
        echo "Alineado: $alineados / Total: $total_archivos / Faltantes: $archivos_faltantes"
        # Mueve el archivo alineado a la carpeta correspondiente
        mv "${archivo}.out" "$carpeta_alineados"
    fi
done

echo "¡Proceso de alineamiento completado! Los archivos alineados se encuentran en la carpeta $carpeta_alineados."
