    ###############################################################################################################################################################
    ### @author Ian Huntress
    ### @description Plot the results of plink distance calculation.
    ###############################################################################################################################################################

#     install.packages("BiocManager")
#     install.packages("tidyverse")
#     BiocManager::install("ComplexHeatmap")

    library(ComplexHeatmap)
    library(tidyverse)
    ###############################################################################################################################################################
    ### Load sampleXsample SNP distances

    outdir="./"

    dist.raw = read_tsv(paste(outdir,"/plink.mdist", sep=""), col_names = FALSE)
    dist.names = read_tsv(paste(outdir,"/plink.mdist.id", sep=""), col_names = c("rid","id")) %>% mutate(rid = str_replace(rid, ".Aligned.sorted.bam",""))

    colnames(dist.raw) <- dist.names$rid
    dist = dist.raw %>% mutate(rid = dist.names$rid) %>% select(rid, everything())

    ### Join in metadata if you have it.
#     dist.summary = dist %>% left_join(meta) %>% mutate(Animal_Outcome_col = hue_pal()(length(levels(Animal_Outcome)))[Animal_Outcome] )
    dist.summary = dist

    dist.mat = dist.summary %>% select(rid, where(is.numeric)) %>% column_to_rownames("rid") %>% as.matrix %>% replace(is.nan(.) | !is.finite(.), 1)

    ###############################################################################################################################################################
    ### genomic distances between samples heatmap.



    fh = function(x) { x %>% as.dist %>% hclust }

    pdf(file.path(outdir, "Plink_SNP_Distance_Heatmap.pdf"), width = 11, height = 8.5)

    HT = ComplexHeatmap::Heatmap(dist.mat, name = "1-ibs", cluster_rows = fh, cluster_columns = fh, column_names_rot=70)
#         row_names_gp = gpar(fontsize = 4),  column_names_gp = gpar(fontsize = 4),
        draw(HT);

    dev.off()

    ###############################################################################################################################################################
