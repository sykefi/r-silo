candidates_to_population <- function(candidates, v) {
    population <- apply(
        candidates,
        1,
        \(x, n) {
            population <- rep(FALSE, n)
            population[match(x, v)] <- TRUE
            return(population)
        },
        n = atomic_size(v)
    )

    if (length(v) == 1) {
        rownames(population) <- seq.int(v)
    } else {
        rownames(population) <- v
    }

    return(population)
}
