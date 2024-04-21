# About me
This is a repository hosting all scripts used during the bartonella virulence project. It features all bioinformatics and statistics scripts used. For more enquires, please send me an e-mail at castillo.vilcahuaman@gmail.com.
# Configuration of this repository
## Directory tree
```
.
├── concatenate_genes_bartonella.sh
├── mafft_bartonella.sh
├── raxml_genes_bartonella.sh
└── README.md

0 directories, 4 files
```
## Documentation regarding the scripts
- `mafft_bartonella.sh`: Used to reiterate `mafft` on all extracted virulence genes
- `raxml_genes_bartonella.sh`: Used to reiterate `raxml` on all aligned genes.
- `concatenate_genes_bartonella.sh`: Used to concatenate all genes according to a category. It used `seqkit` and `mafft` or `iqtree` if needed
## Status
### 21/04/2024
- Uploaded the scripts `concatenate_genes_bartonella.sh`
