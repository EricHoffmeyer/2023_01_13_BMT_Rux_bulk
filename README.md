# 2023_01_13_BMT_Rux_bulk

This repository contains the analysis of a bulk RNAseq dataset generated in January 2023.

The initial analysis was done by our floor bionformatician, Tzu Phang. Most of his initial analysis looked at comparing the individual groups and intra mouse strain. For example, CD4 mixed HLA B vs CD4 Rejection (also HLA B). I will repeat that analysis but I will also make higher groups for DESeq. For example, CD4 T cells from both mixed conditions (HLA B and D) vs CD4 T cells from both Autologous groups (HLA B and D). The idea is that the comparisons among the smaller groups will show pathways that are more specific or point towards mechanism of action. Hopefully these pathways will still be present in the higher group comparisons, though they may not be the top hits.

Briefly, mice were given bone marrow transplants ("BMT") with the following conditions:
- Balb/c bone marrow into C57BL/6 (AKA black 6 or B6) irradiated with 6.5Gy (rejection condition)
- Balb/c bone marrow into Balb/c mice with ~10Gy irradiation (autologous acceptance, Balb/c)
- B6 bone marrow into B6 mice with 13Gy irradiation (autologous acceptance, B6)
- Balb/c bone marrow into B6 mice, 6.5Gy irradiation + Ruxolitinib treatment (allogenic acceptance/mixed chimerism)

Mice were irradiated at Day -1 and the BMT was performed at Day 0. Ruxolitinib treatment was given from Day -5 to Day +28. Mice were sacked at D35.

Additional data for control CD4 and CD8 T cells (isolated from spleens) was brought in from GEO to use as another control. I was only able to find the data for B6 mice.

Folders contain the following:

## 2023_11_09_results
Results from to 2023_11_09_bulk_processing.qmd where one subset of the data is put into the DESeq pipeline.

## 2024_01_10_Condition_DESeqs
Results from 2024_01_10_Condition_DESeqs.qmd where the subset DESeq process is made into a function and used to analyze all the other condition comparisons. Variable for GeneTonic are also generated and stored.

## 2024_01_11_Group_DESeqs
Results from 2024_01_11_Group_DESeqs where conditions are combined to form larger subsets, then run through the DESeq/GeneTonic results function.

## 2024_01_19_Condition_Plots
Results from 2024_01_19_Condition_Plots.qmd where heatmaps, volcano plots, and gene set enrichment plots are generated.

## 2024_02_09_Code_Review.qmd
This notebook was created for a lab code review meeting. It combines the walkthroughs and functions used to create DESeq results, GeneTonic objects, and resulting plots. It references the same result folders: 2024_01_10_Condition_DESeqs and 2024_01_19_Condition_Plots.

## 2024_03_21_

Took the DESeq results and ran them through gprofiler for gene set analysis with more ontologies.

2024_03_26_results

Workbook detailing some Venn Diagrams made for a scientific talk.


