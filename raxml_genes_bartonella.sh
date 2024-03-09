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
        # Ejecutar raxml con el archivo de alineamiento
        # GTR+GAMMA útil para ADN
        raxmlHPC-PTHREADS-SSE3 -f a -m GTRGAMMA -p 12345 -x 12345 -# 100 -s alineacion_genes.fasta -n arbol_genes
    fi
done

