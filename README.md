# SiMLR Examples in Public Data

## Requirements/Libraries

PTBP data - download - details below.

R data packages
```
require( gliomaData ) # see Below
```

R packages

```
library(ANTsR)  # github/neuroconductor
library(ggplot2)  # CRAN
library(RGCCA)  # CRAN
library(BGLR)  # CRAN
library(r.jive) # external package with example data for BRCA => try github
library(ggfortify) # CRAN
library(pander)  # CRAN
library(randomForestExplainer) # CRAN
library(visreg) # CRAN
library(randomForest) # CRAN
```

## Docker

One can access `ANTsR` via docker container.  Try these resources:

[dorianps docker containers](https://github.com/dorianps/docker)

## Examples

Example scripts and pointers to data for testing simlr and comparing its
application to related methods.

1. Glioma data: Clustering

This 3-view example illustrates how we can cluster data based on simlr dimensionality
reduction.

```
rmarkdown::render("simlr_Tumor.Rmd")
```

The data for the glioma example is hosted publicly.  Download the file
[http://biodev.cea.fr/sgcca/gliomaData_0.4.tar.gz](http://biodev.cea.fr/sgcca/gliomaData_0.4.tar.gz)
then call `R CMD INSTALL gliomaData_0.4.tar.gz` to make it accessible in your
`R` environment.

- Result: a simple unsupervised clustering plot.


2. Mouse snps and BMI:  Regression

This 2-view genotype-phenotype example shows how a low-dimensional model may be
learned from high-dimensional data to predict an outcome in a testing set.

```
rmarkdown::render("simlr_BGLR_mouse2.Rmd")
```

The data is available in the `R` package `BGLR`.

- Result: a random forest based prediction of body mass index from SNPs in test data.


3. Pediatric template of brain perfusion (PTBP): SiMLR and SVD Component
regression for brain age and related measurements

download [this data](https://figshare.com/articles/PTBP_Matrices/11900229)
to the data directory.

here, we use simlr in "discovery" mode to learn sparse representations of
cross-modality brain networks that we may then interrogate for relationships
to cognition and related measurements.

```
rmarkdown::render("simlr_PTBP.Rmd")
```

- Result: a random forest and linear regression based prediction of a variety
of univariate outcomes, along with visualization.  Long-running example.


4. Simulation data: Decode known latent signal and perform permutation testing
on the relationship to determine empirical distribution (significance).  Compare with SVD.

simulate known signal and recover it with simlr - also demonstrates a simple
comparison to SVD and to permuted data.

```
rmarkdown::render("simlr_Simulation.Rmd")
```

Note: every run re-simulates the input data, re-runs SiMLR and SVD and compares
the findings to the same applied to permuted data.  In a real example, you would
only run SiMLR and SVD on permuted data in each loop.

- Result: Demonstrate well-above chance recovery of latent signal competitive
with SVD.


5. BRCA: Data clustering

demonstrates data-driven supervised clustering and variance explained in 3-view
BRCA/gene-related data.

```
rmarkdown::render("simlr_BRCA.Rmd")
```

- Result: SiMLR and RGCCA both are able to perform supervised clustering successfully
as shown by the group separation plot.


## Run all examples

Once you have the above setup:

```
energyType = 'regression'
rmarkdown::render("simlr_Tumor.Rmd")
rmarkdown::render("simlr_BRCA.Rmd")
rmarkdown::render("simlr_Simulation.Rmd")
rmarkdown::render("simlr_BGLR_mouse2.Rmd")
rmarkdown::render("simlr_PTBP.Rmd")
```
