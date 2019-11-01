# figtabeqr

An RStudio addin to help add references to figures, tables or equations into Bookdown documents. 


## Installation

At the moment you can only install the package from Github 

```r
remotes::install_github('aj2duncan/figeqr')
```

## Usage

Once the package is installed an addin to *Insert Figure, Table or Equation References*. The addin scans the currently open document, which should be a Bookdown `.Rmd` file, and all other `.Rmd` files in the same directory. It finds all equation labels and `R` chunk labels and presents these to the user. 

The user can choose between figure, table or equation references, choose a label to insert and the addin will insert either `\@ref(fig:label)`, `\@ref(tab:label)` or `\@ref(eq:label)` adding the Bookdown syntax required.
