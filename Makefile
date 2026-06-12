MAKEFLAGS += --no-builtin-rules
.SUFFIXES:
.DEFAULT_GOAL = default

VERSION := $(shell grep "^Version" silo/DESCRIPTION | cut -d " " -f 2)
SILO := silo_${VERSION}.tar.gz

.PHONY: default clean install check test rcpp format

default:

clean:
	git clean -nXd

${SILO}: rcpp
	R CMD build --user="Torsti Schulz" silo

install: ${SILO}
	R CMD INSTALL --use-vanilla $<

check: ${SILO}
	R CMD check --as-cran $<

test:
	R --vanilla -e "tinytest::build_install_test('silo')"

rcpp:
	cd silo && R --vanilla -e "Rcpp::compileAttributes()"

format:
	clang-format --style="{BasedOnStyle: Microsoft, BreakBeforeBraces: Attach}" -i silo/src/*.cpp
	cd silo && R --vanilla -e "styler::style_pkg(indent_by = 4)" -e "styler::style_dir('inst/tinytest', indent_by = 4)"
