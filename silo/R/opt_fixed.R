fixed_score <- function(model, k, nbest = 1) {
    validate_optimization_input()

    set <- model$set
    fixed_idx <- model$fixed_idx

    k_fixed <- length(fixed_idx)

    res <- list(
        score = score_sum(fixed_idx, NULL, model$components, model$weights), rank = c(),
        rank = RcppAlgos::comboRank(fixed_idx, v = set),
        subset = matrix(fixed_idx, nrow = 1),
        search = list()
    )

    validate_optimization_output()

    return(res)
}
