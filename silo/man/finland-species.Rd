\name{finland_species}
\docType{data}
\alias{finland_species}
\title{
  Finnish species and their conservation status
}
\description{
  A list of species in Finland, their taxonomic classification, and conservation status.
}
\usage{
finland_species
}
\format{
  \describe{
    \item{\code{Id}}{
      Identifier of the species in the FinBIF database.
    }
    \item{\code{Order}}{
      Taxonomic Order of the species.
    }
    \item{\code{Family}}{
      Taxonomic Family of the species.
    }
    \item{\code{Scientific.name}}{
      Taxonomic name of the species.
    }
    \item{\code{IUCN.status}}{
      Abbreviation of the IUCN conservation status as assessed
      nationally for the Red List.
    }
    \item{\code{Primary.environment.simple}}{
      Name of the primary environment the species occurs in. Simplified
      from the habitat classification used in the Red List assessment.
    }
    \item{\code{EU.directive.annexes}}{
      Boolean value indicating whether the species is listed in Annex I of
      the EU Habitats Directive.
    }
  }
}
\source{
  \emph{The 2019 Red List of Finnish Species: data download (version 2)}
  Ministry of the Environment & Finnish Environment Institute (2019)
  \url{https://punainenkirja.laji.fi/publications} (retrieved 2026-07-01)

  \emph{FinBIF 2026: The FinBIF checklist of Finnish species 2025}
  Finnish Biodiversity Information Facility, Finnish Museum of Natural History (2026)
  \url{https://info.laji.fi/en/frontpage/checklist/} (retrieved 2026-07-01)
}

\references{
  \emph{Suomen lajien uhanalaisuus: Punainen kirja 2019} (Red List of Finnish Species)
  E. Hyvärinen, A. Juslén, E. Kemppainen, A. Uddström and U.-M. Liukko eds. (2019)
}
\keyword{datasets}
