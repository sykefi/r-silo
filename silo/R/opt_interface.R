validate_optimization_input <- function() {
    with(
        as.list(parent.frame()),
        {
            stopifnot(is_simple_integer(k))
            stopifnot(is_simple_integer(nbest))
            stopifnot(k < length(model$set))
            stopifnot(nbest >= 1)
            stopifnot(nbest < RcppAlgos::comboCount(length(model$set), k))
        }
    )
}

validate_optimization_output <- function() {
    with(
        as.list(parent.frame()),
        {
            stopifnot(setequal(names(res), c("score", "rank", "subset", "search")))
        }
    )
}

optimization_methods <- function() {
    f_list <- list(
        "genetic_algorithm" = genetic_algorithm,
        "global_search" = global_search,
        "local_search" = local_search,
        "fixed_score" = fixed_score
    )

    return(f_list)
}

valid_optimization_method <- function(x) {
    stopifnot(is.element(x, names(optimization_methods())))
}

optimization_f <- function(method) {
    f_list <- optimization_methods()

    valid_optimization_method(method)

    return(f_list[[method]])
}


generate_init <- function(model, k, init) {
    if (!is.null(model$fixed_idx)) {
        k <- k - length(model$fixed_idx)
    }

    if (is.list(init)) {
        if (length(init) == 0) {
            stopifnot(FALSE)
        }

        if (length(init) == 1) {
            init_name <- names(init)
            if (!is.null(init_name) && init_name %in% c("random", "weighted")) {
                if (init_name == "random") {
                    init <- random_init(model, k, size = init[["random"]])
                } else {
                    init <- weighted_random_init(model, k, size = init[["weighted"]])
                }
            } else {
                init <- matrix(setdiff(init[[1]], model$fixed_idx), nrow = 1, ncol = length(init[[1]]))
            }
        } else {
            init <- lapply(init, \(x) setdiff(x, model$fixed_idx)) |> Reduce(rbind, x = _)
        }
    } else {
        if (init == "random") {
            init <- random_init(model, k)

            return(init)
        }

        if (init == "weighted") {
            model$components <- model$full_components
            init <- weighted_random_init(model, k)

            return(init)
        }

        stopifnot(FALSE)
    }

    return(init)
}

filter_best_results <- function(results, nbest) {
    n_res <- length(results)

    if (n_res == 1) {
        res <- results[[1]]
    } else {
        res <- list(
            score = lapply(results, "[[", i = "score") |> Reduce(c, x = _),
            rank = lapply(results, "[[", i = "rank") |> Reduce(c, x = _),
            subset = lapply(results, "[[", i = "subset") |> Reduce(rbind, x = _),
            search = results[[1]]$search
        )
    }

    idx <- head(order(res$score, decreasing = TRUE), nbest)

    res <- list(
        score = res$score[idx],
        rank = res$rank[idx],
        subset = res$subset[idx, , drop = FALSE],
        search = res$search
    )

    return(res)
}
