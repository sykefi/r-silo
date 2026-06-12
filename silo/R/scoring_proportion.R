hellinger_proportion_1m2 <- function(candidates, reference_proportion) {
    candidate_table <- table(candidates)
    candidate_proportion <- proportions(candidate_table)

    h2_1m <- sqrt(candidate_proportion * reference_proportion) / candidate_table

    scores <- h2_1m[candidates]

    return(scores)
}
