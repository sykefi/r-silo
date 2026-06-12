is_simple_integer <- function(x) {
    return(is.finite(x) && is.atomic(x) && length(x) == 1L && as.integer(x) == x)
}

atomic_size <- function(x) {
    stopifnot(is.atomic(x))

    if (length(x) == 1L) {
        stopifnot(x >= 1)
        stopifnot(is_simple_integer(x))

        return(x)
    } else {
        return(length(x))
    }
}

set_size <- function(x) {
    return(sum(table(x) > 0))
}
