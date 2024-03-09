#!/bin/bash

# Contar la cantidad de archivos en la carpeta actual
num_archivos=$(find . -maxdepth 1 -type f | wc -l)
echo "Cantidad de archivos en la carpeta actual: $num_archivos"

# Iterar sobre los archivos y ejecutar raxml para cada uno
for archivo in *; do
    if [ -f "$archivo" ]; then
        # Ejecutar raxml con el archivo de alineamiento
        raxml -s "$archivo" -n "${archivo%.fasta}.tree"
    fi
done

