construct_scoring_function <- function(f, data, param) {
    score_f <- function(idx, fixed_subset = NULL) {
        idx <- c(idx, fixed_subset)

        score <- do.call(f, append(data[idx, , drop = FALSE], param))
        names(score) <- idx

        return(score)
    }

    return(score_f)
}

construct_component <- function(formula_term, set, data, k, config.model = NULL) {
    call_list <- as.list(formula_term)

    f_name <- as.character(call_list[[1]])
    call_list <- call_list[-1]

    name_idx <- nzchar(names(call_list))

    if (length(name_idx) == 0) {
        name_idx <- rep(FALSE, length(call_list))
    }

    named_args <- call_list[name_idx]
    var_names <- call_list[!name_idx]

    var_names <- sapply(var_names, as.character) |> unlist()

    n_var <- length(var_names)

    if (!"name" %in% names(named_args)) {
        name <- paste0(var_names, collapse = "|")
    } else {
        name_pos <- which(names(named_args) == "name")
        name <- named_args[[name_pos]]

        named_args <- named_args[-name_pos]
    }

    if ("transformation_functions" %in% names(config.model) && f_name %in% config.model$transformation_functions) {
        transform_f <- config.model$transformation_functions[[f_name]]
    } else {
        cols_as_factors <- \(x) {
            rn <- rownames(x)
            x <- lapply(x, as.factor) |> as.data.frame()
            rownames(x) <- rn
            return(x)
        }

        transform_f <- list(
            evenness = cols_as_factors,
            score = identity,
            proportion = cols_as_factors
        )[[f_name]]
    }

    data <- transform_f(data[var_names])

    data <- unname(data)
    rownames(data) <- set

    if ("functions" %in% names(config.model) && f_name %in% config.model$functions) {
        f_obj <- config.model$functions[[f_name]]
    } else {
        f_obj <- list(
            evenness = shannon_evenness,
            score = binary_score,
            proportion = hellinger_proportion_1m2
        )[[f_name]]
    }

    if ("param_functions" %in% names(config.model) && f_name %in% config.model$param_functions) {
        param_f <- config.model$param_functions[[f_name]]
    } else {
        param_f <- list(
            evenness = \(param, data, k) {
                new_param <- list()

                if (!"subset" %in% names(param)) {
                    new_param$subset <- TRUE
                }

                if (!"S" %in% names(param)) {
                    if (!"relative" %in% names(param) || param$relative) {
                        new_param$S <- length(table(data))
                    }
                }

                if ("relative" %in% names(param)) {
                    param <- within(param, rm("relative"))
                }

                return(append(param, new_param))
            },
            score = \(param, data, k) {
                return(append(param, list(S = min(k, sum(as.logical(data[[1]]))))))
            },
            proportion = \(param, data, k) {
                return(append(param, list(reference_proportion = proportions(table(data)))))
            }
        )[[f_name]]
    }

    if (is.null(param_f)) {
        param <- named_args
    } else {
        param <- param_f(named_args, data, k)
    }

    scoring_args <- list(
        f = f_obj,
        data = data,
        param = param
    )

    score_f <- do.call(construct_scoring_function, args = scoring_args)

    attr(score_f, "name") <- name

    return(score_f)
}
