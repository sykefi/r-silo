expect_true(
    is.data.frame(silo::finland_species)
)

expect_true(
    nrow(silo::finland_species) > 0
)

expect_true(
    apply(silo::finland_species, 2, \(x) {
        sum(is.na(x))
    } == 0) |> all(),
    "Example data should have no missing data in variables."
)

expect_equal(
    colnames(silo::finland_species),
    c("Id", "Order", "Family", "Scientific.name", "IUCN.status", "Primary.environment.simple", "EU.directive.annexes")
)
