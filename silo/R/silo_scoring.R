scoring_function <- function(subset, fixed_subset, components) {
    scores <- lapply(
        components,
        \(x, subset, fixed_subset) {
            x(subset, fixed_subset)
        },
        subset = subset,
        fixed_subset = fixed_subset
    ) |> Reduce(cbind, x = _)

    colnames(scores) <- names(components)

    return(scores)
}

score_sum <- function(subset, fixed_subset, components, w) {
    sum(colSums(scoring_function(subset, fixed_subset, components)) * w[names(components)]) / sum(w)
}
