library("openxlsx2")

# NOTE: Update inst/COPYRIGHTS when updating source files

RedList_url <- "https://cdn.laji.fi/files/red-book/Lajien_uhanalaisuusarviointi_2019_v2_17052019.xlsx"
Checklist_url <- "https://cdn.laji.fi/files/checklists/2025/Liite1_Appendix1_Lajiluettelo2025_Checklist2025.xlsx"

RedList <- read_xlsx(RedList_url, col_names = TRUE)
Checklist <- read_xlsx(Checklist_url, col_names = TRUE)

idx <- which(names(RedList) == "Luokka")
RedList <- RedList[, -idx[2]]

RedList <-
    RedList[, !names(RedList) %in% c(
        "Ryhmä 1",
        "Ryhmä 2",
        "Ryhmä 3",
        "ARVIOINNIN TIEDOT ALKAVAT",
        "1a Hemiboreaalinen, Ahvenanmaa",
        "1b Hemiboreaalinen, Lounainen rannikkomaa",
        "2a Eteläboreaalinen, Lounaismaa ja Pohjanmaan rannikko",
        "2b Eteläboreaalinen, Järvi-Suomi",
        "3a Keskiboreaalinen, Pohjanmaa",
        "3b Keskiboreaalinen, Pohjois-Karjala - Kainuu",
        "3c Keskiboreaalinen, Lapin kolmio",
        "4a Pohjoisboreaalinen, Koillismaa",
        "4b Pohjoisboreaalinen, Perä-Pohjola",
        "4c Pohjoisboreaalinen, Metsä-Lappi",
        "4d Pohjoisboreaalinen, Tunturi-Lappi",
        "Uhanalaisuuden syyt",
        "Uhkatekijät",
        "Kriteerit",
        "Alentaminen/ korottaminen",
        "Muutoksen syy",
        "Mahd. hävinnyt",
        "Viimeisin havainto (julkinen)"
    )]


RedList_colnames <- c(
    "Id",
    "Order.Family",
    "Taxonomic.level",
    "Scientific.name",
    "Author",
    "Synonyms",
    "Finnish.name",
    "Swedish.name",
    "English.name",
    "Admin.status",
    "IUCN.status",
    "IUCN.status.2010.2015",
    "Primary.environment",
    "Other.environments"
)

colnames(RedList) <- RedList_colnames


RedList$IUCN.status <- gsub("●|°", "", RedList$IUCN.status)
RedList <- RedList[!is.na(RedList$IUCN.status), ]


RedList$Primary.environment[RedList$Primary.environment == "?"] <- NA

EnvironmentSubstitution <- list(
    "Forest" = c("^M"),
    "Mire" = c("^S"),
    "Baltic.Sea" = c("^Vi"),
    "Inland.freshwaters" = c("^Vs", "^Vp", "^Vl", "^Va", "^Vk", "^Vj"),
    "Shores" = c("^R"),
    "Fells.and.alpine" = c("^T"),
    "Agri.environments" = c("^I$", "^I ", "^In", "^It", "^Ih", "^Ik", "^Iv", "^Io"),
    "Built.environments" = c("^Ip", "^Ir", "^Iu"),
    "Rocks.cliffs" = c("^K")
)

EnvironmentSubstitution <- mapply(
    \(a, b) {
        sapply(a, \(x) {
            x <- b
        })
    },
    EnvironmentSubstitution,
    names(EnvironmentSubstitution)
) |>
    unname() |>
    unlist()

RedList$Primary.environment.simple <- NA

for (x in names(EnvironmentSubstitution)) {
    RedList$Primary.environment.simple[(grep(x, RedList$Primary.environment))] <- EnvironmentSubstitution[[x]]
}

RedList <- RedList[!is.na(RedList$Primary.environment.simple), ]


split_status <- lapply(RedList$Admin.status, \(x) {
    strsplit(x, split = ",(?!([^(]*\\)| Kainuun))", perl = TRUE) |> lapply(trimws)
})
status_list <- unlist(split_status) |>
    unique() |>
    (\(x) x[!is.na(x)])() |>
    sort()

status_matrix <- lapply(split_status, \(x) {
    status_list %in% unlist(x)
}) |> Reduce(rbind, x = _)
colnames(status_matrix) <- status_list

annexes <- c("EU:n lintudirektiivin I-liite", "EU:n luontodirektiivin II-liite", "EU:n luontodirektiivin IV-liite")

RedList$EU.directive.annexes <- apply(status_matrix[, annexes], 1, any)


RedList <- subset(RedList, Taxonomic.level == "species")
RedList <- subset(RedList, !is.na(Order.Family))

order_family_split <- strsplit(RedList$Order.Family, ", ")
order_family_split_length <- lapply(order_family_split, length) |> unlist()
order_family_suffix <- sapply(RedList$Order.Family[order_family_split_length == 1], \(x) {
    substr(x, nchar(x) - 2, nchar(x))
})

RedList$Order <- NA
RedList$Family <- NA

RedList$Order[order_family_split_length == 2] <- lapply(order_family_split[order_family_split_length == 2], \(x) {
    x[[1]]
}) |> unlist()
RedList$Family[order_family_split_length == 2] <- lapply(order_family_split[order_family_split_length == 2], \(x) {
    x[[2]]
}) |> unlist()

RedList$Order[order_family_split_length == 3] <- lapply(order_family_split[order_family_split_length == 3], \(x) {
    x[[1]]
}) |> unlist()

RedList$Order[order_family_split_length == 1][order_family_suffix %in% c("era", "les")] <- RedList$Order.Family[order_family_split_length == 1][order_family_suffix %in% c("era", "les")]
RedList$Family[order_family_split_length == 1][order_family_suffix %in% c("dae", "eae")] <- RedList$Order.Family[order_family_split_length == 1][order_family_suffix %in% c("dae", "eae")]


RedList <- subset(RedList, !is.na(Order) & !is.na(Family))

finland_species <- RedList[, c("Id", "Order", "Family", "Scientific.name", "IUCN.status", "Primary.environment.simple", "EU.directive.annexes")]

args <- commandArgs(trailingOnly = FALSE)
match <- grep("--file=", args)

script_dir <- dirname(substring(args[match], 8))

data_file <- file.path(script_dir, "..", "silo", "data", "finland_species.rda")

save(finland_species, file = data_file, compress = "xz")
