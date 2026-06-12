local_search <- function(model, k, nbest = 1, config = NULL, init = NULL) {
    validate_optimization_input()

    full_set <- model$set
    fixed_idx <- model$fixed_idx

    full_k <- k

    if (!is.null(fixed_idx)) {
        k <- k - length(fixed_idx)
        optimization_set <- setdiff(full_set, fixed_idx)
    } else {
        optimization_set <- model$set
    }

    ls_opts <- list()

    if (!is.null(config)) {
        m <- config$m
        stopifnot(m < k)

        iter <- config$iter
    } else {
        m <- 1
        iter <- 1000
    }

    neighbour_fun <- function(candidate, ...) {
        neighbour <- sort(
            c(
                candidate[!candidate %in% sample(candidate, m)],
                sample(optimization_set[!optimization_set %in% candidate], m)
            )
        )
        return(neighbour)
    }

    ls_opts$neighbour <- neighbour_fun
    ls_opts$printDetail <- FALSE
    ls_opts$printBar <- FALSE
    ls_opts$storeSolutions <- TRUE

    ls_opts$nS <- iter

    if (is.null(init)) {
        init <- random_combination(optimization_set, k)
    } else {
        init <- generate_init(model, full_k, init)
    }

    n_init <- nrow(init)
    res_list <- list()

    for (i in seq_len(n_init)) {
        ls_opts$x0 <- init[i, ]

        solution <- NMOF::LSopt(
            OF = \(x, fixed_subset, model) {
                return(-score_sum(x, fixed_idx, model$components, model$weights))
            },
            algo = ls_opts,
            model = model,
            fixed_subset = fixed_idx
        )

        scores <- -c(solution$Fmat[, 1], solution$Fmat[, 2])
        subsets <- c(solution$xlist[[1]], solution$xlist[[2]]) |> Reduce(rbind, x = _)

        if (length(fixed_idx) > 0) {
            subsets <- apply(subsets, 1, \(x) sort(c(fixed_idx, x))) |> t()
        }

        ranks <- RcppAlgos::comboRank(subsets, v = full_set)

        unique_idx <- tapply(seq_along(ranks), ranks, identity) |> sapply(head, n = 1)

        scores <- scores[unique_idx]
        subsets <- subsets[unique_idx, , drop = FALSE]
        ranks <- ranks[unique_idx]

        sort_idx <- sort.list(scores, decreasing = TRUE)

        res <- list(
            score = head(scores[sort_idx], nbest),
            rank = head(ranks[sort_idx], nbest),
            subset = head(subsets[sort_idx, , drop = FALSE], nbest),
            search = c(list(nbest = nbest), config)
        )

        res_list[[i]] <- res
    }


    res <- filter_best_results(res_list, nbest)

    validate_optimization_output()

    return(res)
}
