#!/bin/bash

#--------------------------------------------------------------
#Version 1: raxml with minimal parameters
#--------------------------------------------------------------

# Activar conda

conda activate
conda activate raxml

# Contar la cantidad de archivos en la carpeta actual
num_archivos=$(find . -maxdepth 1 -type f | wc -l)
echo "Cantidad de archivos en la carpeta actual: $num_archivos"

# Iterar sobre los archivos y ejecutar raxml para cada uno
for archivo in *; do
    if [ -f "$archivo" ]; then
        # Extraer nombre
        base_name=$(basename "$fasta_file" .out)
        # Crear un directorio específico para esta iteración
        mkdir -p "$base_name"
        # Ejecutar raxml con el archivo de alineamiento
        # GTR+GAMMA útil para ADN y proteína
        raxmlHPC-PTHREADS-SSE3 -f a -m GTRGAMMA -p 12345 -x 12345 -# 100 -s "$archivo" -n "${archivo}_gene.tree"
        # Mover archivos a carpeta generada
        mv RAxML_* "$base_name"
    
    fi
done

