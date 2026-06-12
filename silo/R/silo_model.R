silo_model <- function(formula, data, k, w, fixed = NULL, config.model = NULL) {
    stopifnot(is.element("formula", class(formula)) & deparse(formula[[1]]) == "~")

    model_data <- data

    has_lhs <- length(formula) == 3

    if (has_lhs) {
        lhs <- deparse(formula[[2]])

        formula <- formula[c(1, 3)]

        stopifnot(is.element(lhs, colnames(data)))

        lhs <- model_data[, lhs]

        stopifnot(length(lhs) == length(unique(lhs)))

        rownames(model_data) <- lhs
    }

    set <- rownames(model_data)
    formula_terms <- terms(formula)

    components <- attr(formula_terms, "variables", TRUE)[-1] |>
        lapply(construct_component, set = set, data = data, k = k, config.model = config.model)
    names(components) <- lapply(components, attr, which = "name", exact = TRUE) |> unlist()

    full_components <- attr(formula_terms, "variables", TRUE)[-1] |>
        lapply(construct_component, set = set, data = data, k = nrow(data), config.model = config.model)
    names(full_components) <- names(components)

    term_order <- attr(terms(formula), "order", TRUE)
    stopifnot(all(term_order == 1))

    model <- list(
        components = components,
        set = set,
        weights = unlist(w[names(components)]),
        fixed_idx = fixed,
        full_components = full_components
    )

    return(model)
}
