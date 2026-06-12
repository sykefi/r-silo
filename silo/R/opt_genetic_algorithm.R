genetic_algorithm <- function(model, k, nbest = 1, config = NULL, init = NULL) {
    validate_optimization_input()

    full_set <- model$set
    fixed_idx <- model$fixed_idx

    if (!is.null(fixed_idx)) {
        k <- k - length(fixed_idx)
        optimization_set <- setdiff(full_set, fixed_idx)
    } else {
        optimization_set <- model$set
    }

    n <- length(optimization_set)

    solution <- do.call(
        kofnGA::kofnGA,
        args = list(
            n = n,
            k = k,
            OF = \(x, model, set, fixed_subset) {
                return(-score_sum(set[x], fixed_subset, model$components, model$weights))
            },
            model = model,
            set = optimization_set,
            fixed_subset = fixed_idx
        )
    )

    subsets <- apply(
        solution$pop[1:nbest, , drop = FALSE],
        1,
        \(x) {
            return(sort(c(optimization_set[x], fixed_idx)))
        }
    ) |> t()

    res <- list(
        score = -head(solution$obj, nbest),
        rank = RcppAlgos::comboRank(subsets, v = full_set),
        subset = subsets,
        search = c(list(nbest = nbest), config)
    )

    validate_optimization_output()

    return(res)
}
