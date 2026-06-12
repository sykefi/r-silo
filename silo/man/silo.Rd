\name{silo}
\alias{silo}

\title{
  Find Optimal Species List Based on Multiple Criteria
}

\description{
  \code{silo} looks for an optimal subset of species with regards to on
  multiple scoring criteria.
}

\usage{
silo(formula, data, k, w, fixed = NULL, constraints = NULL,
  method = "local_search", init = NULL, nbest = 1, config.model = NULL,
  config.method = NULL)
}

\arguments{
\item{formula}{
  Formula describing the scoring criteria. An optional left-hand side denotes
  the variable containing the (unique) species names or identifiers.
}

\item{data}{
  Data frame containing the species and their properties for the optimization.
}

\item{k}{
  For fixed subset selection the desired number of species in the target list.
}

\item{w}{
  Weights for adjusting the role of the different criteria in \code{formula}.
  A list with either the names of the variables used in the scoring functions
  or the explicit names passed to the functions using the \code{name}
  -argument.
}

\item{fixed}{
  Vector of species names or identifiers (or optionally row numbers if the LHS
  is omitted) that should always be included in the selected subset.
}

\item{constraints}{
  Not implemented.
}

\item{method}{
  Optimization method. One of \emph{local_search}, \emph{global_search},
  \emph{genetic_algorithm}, or \emph{fixed_score}. \emph{fixed_score}
  calculates the score for a predefined list provided via the \code{fixed}
  argument and performs no optimization.
}

\item{init}{Choice of initialization for the optimization algorithm.}

\item{nbest}{Number of optimization results to return.}

\item{config.model}{
  Options passed to change the behaviour of the scoring formula.
}

\item{config.method}{
  Options passed to customize the behaviour of the optimization method.
}
}

\details{
  The default behaviour depends on whether a fixed number of species is
  selected or whether \code{k} is allowed to vary. The latter functionality
  is not yet implemented.
}

\value{
  \item{score}{The overall scores of the results}
}

\references{
  Pielou, E. C. 1975 \emph{Ecological Diversity}. John Wiley & Sons.
}

\seealso{
  \code{\link[kofnGA]{kofnGA}} for the genetic algorithm, \code{\link[NMOF]{LSopt}} for local search.
}

\keyword{optimize}
\keyword{design}
