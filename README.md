# figeqr

An RStudio addin to help add references to equations and figures into Bookdown documents. 


## Installation

At the moment you can only install the package from Github 

```r
remotes::install_github('aj2duncan/figeqr')
```

## Usage

Once the package is installed an addin to *Insert Figure and Equation References*. The addin scans the currently open document, which should be a Bookdown `.Rmd` file, and finds all equation labels and `R` chunk labels.

The user can choose between figure and equation references, choose a label to insert and the addin will insert either `\@ref(fig:label)` or `\@ref(eq:label)` adding the Bookdown syntax required.
