# Species indicator list optimization using multiple criteria

## Summary

The `silo` R-package is a multi-criteria optimization tool intended for selection of species for monitoring or indicator assessment with an emphasis on representativeness of the selected species list.
The methodology is quite general and should be easily applicable outside of the field of biological and genetic diversity.


## Documentation

The package is documented in its help files and vignettes.
Additionally an upcoming publication will describe overall methodology more generally.


## Installation

To install the development version of this package you have two options:

1) Use the `devtools` R-package.
In an R session run the command `devtools::install_github("sykefi/r-silo", subdir = "silo")`.

2) Clone the repository and install locally.
Run `git clone https://github.com/sykefi/r-silo.git` on the command line, enter the repository `cd r-silo/silo` and run the commands `R CMD build silo`.
Alternatively run the command `make install` if Make is available in the `r-silo/` directory.
Installation on Windows will require [Rtools](https://cran.r-project.org/bin/windows/Rtools/).


## Development

The root directory of the repository contains a `Makefile` that can help with development of the package.
It has the following targets.

- `check`: Run the R CMD check in CRAN mode.
- `clean`: Remove all generated files ignored by the git from the repository.
- `format`: Reformat C++ and R code in the repository.
- `install`: Install the package locally.
- `rcpp`: Create the Rcpp interface files, run automatically by targets requiring it.
- `test`: Run the `tinytest` test suite.

To reattach the package in a running R-session after installing a new version, run

```R
detach("package:silo", unload = TRUE); library("silo")
```
