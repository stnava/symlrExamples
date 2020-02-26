# symlrExamples

example scripts and pointers to data for testing symlr

1. glioma data

This 3-view example illustrates how we can cluster data based on symlr dimensionality
reduction.

```
rmarkdown::render("symlr_Tumor.Rmd")
```

data for the glioma example - download then R CMD INSTALL the tgz file
[http://biodev.cea.fr/sgcca/gliomaData_0.4.tar.gz](http://biodev.cea.fr/sgcca/gliomaData_0.4.tar.gz)


2. mouse snps and BMI

This 2-view genotype-phenotype example shows how a low-dimensional model may be
learned from high-dimensional data to predict an outcome in a testing set.

```
rmarkdown::render("symlr_BGLR_mouse2.Rmd")
```


3. PTBP

download [this data](https://figshare.com/articles/PTBP_Matrices/11900229)
to the data directory.

here, we use SyMLR in "discovery" mode to learn sparse representations of
cross-modality brain networks that relate to cognition and related measurements.

```
rmarkdown::render("symlr_PTBP.Rmd")
```

4. simulation data

simulate known signal and recover it with symlr - also demonstrates a simple
comparison to SVD and to permuted data.

```
rmarkdown::render("symlr_Simulation.Rmd")
```


5. BRCA data clustering

demonstrates data-driven clustering and variance explained in 3-view
BRCA/gene-related data.

```
rmarkdown::render("symlr_BRCA.Rmd")
```
