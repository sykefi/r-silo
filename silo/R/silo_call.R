silo <- function(
  formula,
  data,
  k,
  w,
  fixed = NULL,
  constraints = NULL,
  method = "local_search",
  init = NULL,
  nbest = 1,
  config.model = NULL,
  config.method = NULL
) {
    validate_silo_input()

    n <- nrow(data)

    if (method == "fixed_score" && is.null(k)) {
        k <- length(fixed)
    }

    model <- silo_model(formula, data, k, w, fixed, config.model)

    opt_f <- optimization_f(method)
    opt_args <- list(model = model, k = k, nbest = nbest)

    if (!method %in% c("global_search", "fixed_score")) {
        opt_args <- append(opt_args, list(init = init, config = config.method))
    }

    search_result <- do.call(opt_f, opt_args)

    res <- list()

    res <- search_result
    res$search$method <- method

    res$weights <- model$w

    res$summary <- lapply(seq_len(nbest), \(x) {
        res_summary <- list()
        res_summary$individual_scores <- scoring_function(res$subset[x, , drop = FALSE], NULL, model$components)
        res_summary$component_scores <- colSums(res_summary$individual_scores)
        res_summary$individual_scores <- sweep(res_summary$individual_scores, 2, model$w[names(model$components)], FUN = "*")
        res_summary$component_scores <- rbind(res_summary$component_scores, colSums(res_summary$individual_scores))
        res_summary$individual_scores <- res_summary$individual_scores / sum(model$w)
        res_summary$component_scores <- rbind(res_summary$component_scores, colSums(res_summary$individual_scores))
        rownames(res_summary$component_scores) <- c("original", "weighted", "rescaled")
        res_summary$cov <- var(res_summary$individual_scores)
        res_summary$cov <- res_summary$cov / sum(res_summary$cov)
        res_summary$cor <- suppressWarnings(cov2cor(res_summary$cov))

        return(res_summary)
    })

    class(res) <- "silo"

    validate_silo_output()

    return(res)
}

validate_silo_input <- function() {
    with(
        as.list(parent.frame()),
        {
            valid_optimization_method(method)
            stopifnot(is.data.frame(data))
            stopifnot(is.null(k) || is_simple_integer(k))
            stopifnot(is_simple_integer(nbest))
            stopifnot(is.null(constraints))
            stopifnot(is.null(k) || k < nrow(data))
            stopifnot(nbest >= 1)
            stopifnot(is.null(k) || nbest < RcppAlgos::comboCount(nrow(data), k))
        }
    )
}

validate_silo_output <- function(x, method) {
    with(
        as.list(parent.frame()),
        {
            stopifnot(class(res) == "silo")
        }
    )
}
