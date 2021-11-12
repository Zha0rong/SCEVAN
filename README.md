# Single   CEll   Variational   Aneuploidy aNalysis  (SCEVAN)

![image](https://github.com/AntonioDeFalco/SCEVAN/blob/main/SCEVAN.png)

## Introduction

SCEVAN is an R package that starting from the raw count matrix of scRNA data automatically classifies the cells present in the biopsy by segregating non-malignant cells of tumor microenviroment from the malignant cells and also characterize the clonal structure of this malignant cells, specifically analysing the presence of subpopulations and identifying the specific and shared alterations of each subpopulation.The aim of the tool is to automate the entire analysis by allowing it to be performed in a very simple and completely unsupervised way. Analyses carried out on 106 samples and 93332 cells show better classification with an F1 score for all samples of 0.90 compared to 0.63 obtained with the state-of-the-art CopyKAT, with a better classification in 63% of the samples and worse in only 23% of the samples.

## Installation

```
library(devtools)
install_github("AntonioDeFalco/SCEVAN")
library(SCEVAN)
```

## Usage

### Single-sample analysis
A single call (pipelineCNA) allows the execution of the entire analysis of classification and characterization of clonal structure.

- ***count_mtx*** : Count matrix with genes on rows (both Gene Symbol or Ensembl ID are allowed) and cells on columns.
- ***sample*** : Sample name to save results (optional)
- ***par_cores*** : Number of cores to run the pipeline  (optional)
- ***norm_cells*** : vectors of normal cells if the classification is already known and you are only interested in the clonal structure (optional)
- ***SUBCLONES*** : Boolean value TRUE if you are interested in analysing the clonal structure and FALSE if you are only interested in the classification of malignant and non-malignant cells (optional)

```
results <- pipelineCNA(count_mtx)
```

### Multi-sample analysis
A single call (compareClonalStructure) allows the comparison of clonal profiles of the different samples.

- ***count_mtx1*** : Count matrix of sample 1.
- ***count_mtx2*** : Count matrix of sample 2.
- ***samp_1*** : Name of sample 1.
- ***samp_2*** : Name of sample 2.
- ***par_cores*** : Number of cores to run the pipeline  (optional)

```
compareClonalStructure(count_mtx1, count_mtx2, samp_1, samp_2)
```

## Usage examples (vignettes)

- [Intratumoral heterogeneity](http://htmlpreview.github.io/?https://github.com/AntonioDeFalco/SCEVAN/blob/main/vignettes/IntratumoralHeterogeneityInGlioblastoma.html)
- [Comparison of clonal profiles](http://htmlpreview.github.io/?https://github.com/AntonioDeFalco/SCEVAN/blob/main/vignettes/ComparisonOfClonalProfiles.html)

## Sample Datasets

In the folder ***data*** are provided some pre-processed samples used in the examples (vignettes):

- ***MGH106.RData*** : scRNA data of MGH106 sample from the public dataset of Gliobastoma (GSE131928) 
- ***HNSCC26.RData*** : scRNA data of HNSCC26 Primary and HNSCC26 Lymph Node sample from the public dataset of Head&Neck cancer (GSE10332)

