global_search <- function(model, k, nbest = 1) {
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

    set_iter <- RcppAlgos::comboIter(v = optimization_set, m = k)

    iter <- set_iter@nextIter()

    min <- 0
    res <- list(score = min, rank = c())

    while (!is.null(iter)) {
        score <- score_sum(iter, fixed_idx, model$components, model$weights)

        if (score >= min) {
            iter_rank <- RcppAlgos::comboRank(c(iter, fixed_idx), v = full_set)

            if (nbest > 1) {
                ranks <- c(res$rank, iter_rank)
                scores <- c(res$score, score)

                idx <- tail(order(scores), nbest)

                res <- list(
                    score = scores[idx],
                    rank = ranks[idx]
                )

                min <- res$score[1]
            } else {
                res <- list(rank = iter_rank, score = score)
                min <- score
            }
        }

        capture.output(iter <- set_iter@nextIter())
    }

    res$subset <- RcppAlgos::comboSample(v = full_set, m = k + length(fixed_idx), sampleVec = res$rank)
    res$search <- list(nbest = nbest)

    validate_optimization_output()

    return(res)
}
