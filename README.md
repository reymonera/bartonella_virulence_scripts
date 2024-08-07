# About me
This is a repository hosting all scripts used during the bartonella virulence project. It features all bioinformatics and statistics scripts used. For more enquires, please send me an e-mail at castillo.vilcahuaman@gmail.com.
# Configuration of this repository
## Directory tree
```
.
├── concatenate_genes_bartonella.sh
├── mafft_bartonella.sh
├── paml_script
│   ├── newick_formatter_for_PAML.py
│   └── paml_script_v3.sh
├── process_names.py
├── raxml_genes_bartonella.sh
├── README.md
├── replace_names.sh
└── tanglegram_phylogeny.r

```
## Documentation regarding the scripts
- `mafft_bartonella.sh`: Used to reiterate `mafft` on all extracted virulence genes
- `raxml_genes_bartonella.sh`: Used to reiterate `raxml` on all aligned genes.
- `concatenate_genes_bartonella.sh`: Used to concatenate all genes according to a category. It used `seqkit` and `mafft` or `iqtree` if needed
- `paml_scripts`: These work in a bundle. For now, it creates directories for 2 hypothesis with its corresponding null hypothesis. First, it will interact with the user to modify the input `.newick` tree using `newick_formatter_for_PAML.py` and then it will run and save the outputs in each hypothesis folder. At the end, it will create a `.csv` file containing the results for each hypothesis. 
## Status
### 06/08/2024
- Uploaded the scripts for paml usage in `paml_scripts`
