library(phylogram)
library(ape)
library("dendextend")

metadata <- (c("#009E73", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#56B4E9", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00", "#E69F00"))

coreFileName <- 'core2.treefile'
core <- readChar(coreFileName, file.info(coreFileName)$size)
motilidadFileName <- 'motilidad2.treefile'
motilidad <- readChar(motilidadFileName, file.info(motilidadFileName)$size)
adhesionFileName <- 'adhesion2.treefile'
adhesion <- readChar(adhesionFileName, file.info(adhesionFileName)$size)
hbpFileName <- 'hbp2.treefile'
hbp <- readChar(hbpFileName, file.info(hbpFileName)$size)
dnd1 <- read.dendrogram(text = core)
dnd2 <- read.dendrogram(text = adhesion)

## rearrange in ladderized fashion
dnd1 <- ladder(dnd1)
dnd2 <- ladder(dnd2)
## plot the tanglegram
##dndlist <- dendextend::dendlist(dnd1, dnd2)
##dendextend::tanglegram(dndlist, fast = TRUE, margin_inner = 8)

# Extract labels from dendrogram on the left
labels <- dnd1 %>% set("labels_to_char") %>% labels 

#Using a metadata table with colours create a vector of colours
labels <- as.data.frame(labels)
metadata <- as.data.frame(metadata)
labels2 <- data.frame(Column1 = labels, Column2 = metadata)
cols <- as.character(labels2$metadata)

# Make tanglegram
tanglegram(dnd1, dnd2, color_lines = cols, fast = TRUE, margin_inner = 6)

dnd1_colored <- set(dnd1, "labels_colors", value = cols)
dnd2_colored <- set(dnd2, "labels_colors", value = cols)

# Tanglegram con color en los nodos y títulos en la parte superior

tanglegram(dnd1, dnd2, color_lines = cols, fast = TRUE, margin_inner = 8, 
           lwd = 2, main_left = "Core genes", main_right = "Adherence")