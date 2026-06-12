random_combination <- function(set, k, size = 1) {
    candidates <- RcppAlgos::comboSample(v = set, m = k, n = size, namedSample = TRUE)

    candidate_rank <- as.bigz(rownames(candidates))

    return(candidates[order(candidate_rank), , drop = FALSE])
}

random_init <- function(model, k, size = 1) {
    full_set <- model$set
    fixed_idx <- model$fixed_idx

    if (!is.null(fixed_idx)) {
        k <- k - length(fixed_idx)
        optimization_set <- setdiff(full_set, fixed_idx)
    } else {
        optimization_set <- model$set
    }

    subsets <- random_combination(optimization_set, k, size = size)

    return(subsets)
}


weighted_random_combination <- function(set, k, size = 1, weights = rep(1, atomic_size(set))) {
    gen_candidates <- \(size) {
        array(replicate(n = size, sample(x = set, size = k, prob = weights)), dim = c(k, size)) |>
            apply(2, sort) |>
            array(dim = c(k, size)) |>
            t()
    }

    candidates <- gen_candidates(size)

    candidates <- unique(candidates)

    u <- nrow(candidates)

    while ((size - u) > 0) {
        new_candidates <- gen_candidates(size - u)
        candidates <- unique(rbind(candidates, new_candidates))
        u <- nrow(candidates)
    }

    candidate_rank <- RcppAlgos::comboRank(candidates, v = set)

    rownames(candidates) <- c(as.character(candidate_rank))

    return(candidates[order(candidate_rank), , drop = FALSE])
}

weighted_random_init <- function(model, k, size = 1) {
    full_set <- model$set
    fixed_idx <- model$fixed_idx

    if (!is.null(fixed_idx)) {
        k <- k - length(fixed_idx)
        optimization_set <- setdiff(full_set, fixed_idx)
    } else {
        optimization_set <- model$set
    }

    weights <- rowSums(
        (scoring_function(full_set, NULL, model$components)) * model$weights[names(model$components)]
    ) / sum(unlist(model$weights))

    subsets <- weighted_random_combination(optimization_set, k, size = size, weights = weights[which(optimization_set %in% full_set)])

    return(subsets)
}
