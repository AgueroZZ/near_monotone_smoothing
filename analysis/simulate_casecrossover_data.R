# Helper for simulating case-crossover response counts from the CD3518 sample.
#
# Example:
# source("analysis/simulate_casecrossover_data.R")
# simulated_data <- simulate_casecrossover_data(
#   f_temp = function(x) 0.02 * x,
#   f_pm25 = function(x) 0.03 * sqrt(x),
#   f_no2 = function(x) 0.01 * x,
#   f_o3 = function(x) -0.01 * x,
#   seed = 123
# )
#
# pm25_only_data <- simulate_casecrossover_data(
#   f_pm25 = function(x) 0.1 * log1p(x),
#   stratum_total_cases = 5,
#   seed = 123
# )
#
# original_counts <- tapply(
#   data_CD3518_sample_2$dailymort_pulm_nonsenior,
#   format(data_CD3518_sample_2$Date, "%Y%b%A"),
#   sum,
#   na.rm = TRUE
# )
# original_count_data <- simulate_casecrossover_data(
#   f_pm25 = function(x) 0.1 * log1p(x),
#   stratum_total_cases = original_counts,
#   seed = 123
# )

simulate_casecrossover_data <- function(
  f_temp = NULL, f_pm25 = NULL, f_no2 = NULL, f_o3 = NULL,
  data = NULL,
  data_path = "data/data_CD3518_sample_2.RData",
  seed = NULL,
  stratum_total_cases = NULL
) {
  required_columns <- c(
    "Date",
    "dailymort_pulm_nonsenior",
    "HCtemp",
    "pm25Sample",
    "no2Sample",
    "o3Sample"
  )

  if (is.null(data)) {
    data_env <- new.env(parent = emptyenv())
    loaded_objects <- load(data_path, envir = data_env)

    if (!"data_CD3518_sample_2" %in% loaded_objects) {
      stop(
        "Expected `data_path` to contain an object named `data_CD3518_sample_2`.",
        call. = FALSE
      )
    }

    data <- data_env$data_CD3518_sample_2
  }

  missing_columns <- setdiff(required_columns, names(data))
  if (length(missing_columns) > 0) {
    stop(
      "Missing required columns: ",
      paste(missing_columns, collapse = ", "),
      call. = FALSE
    )
  }

  effect_functions <- list(
    f_temp = f_temp,
    f_pm25 = f_pm25,
    f_no2 = f_no2,
    f_o3 = f_o3
  )

  non_functions <- names(effect_functions)[
    !vapply(effect_functions, function(x) is.null(x) || is.function(x), logical(1))
  ]
  if (length(non_functions) > 0) {
    stop(
      "The following effects must be NULL or functions: ",
      paste(non_functions, collapse = ", "),
      call. = FALSE
    )
  }

  if (!is.null(seed)) {
    if (!is.numeric(seed) || length(seed) != 1 || is.na(seed)) {
      stop("`seed` must be NULL or a single non-missing numeric value.", call. = FALSE)
    }

    old_seed_exists <- exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    if (old_seed_exists) {
      old_seed <- get(".Random.seed", envir = .GlobalEnv, inherits = FALSE)
    }

    on.exit({
      if (old_seed_exists) {
        assign(".Random.seed", old_seed, envir = .GlobalEnv)
      } else if (exists(".Random.seed", envir = .GlobalEnv, inherits = FALSE)) {
        rm(".Random.seed", envir = .GlobalEnv)
      }
    }, add = TRUE)

    set.seed(seed)
  }

  out <- data
  n <- nrow(out)
  out$strata <- format(out$Date, "%Y%b%A")

  if (anyNA(out$strata)) {
    stop("`Date` must not generate missing `strata` values.", call. = FALSE)
  }

  eta <- evaluate_casecrossover_effect(f_temp, out$HCtemp, "f_temp", n) +
    evaluate_casecrossover_effect(f_pm25, out$pm25Sample, "f_pm25", n) +
    evaluate_casecrossover_effect(f_no2, out$no2Sample, "f_no2", n) +
    evaluate_casecrossover_effect(f_o3, out$o3Sample, "f_o3", n)

  if (any(!is.finite(eta))) {
    stop("Computed `eta` must not contain NA, NaN, or infinite values.", call. = FALSE)
  }

  stratum_totals <- resolve_casecrossover_stratum_totals(
    stratum_total_cases = stratum_total_cases,
    response = out$dailymort_pulm_nonsenior,
    strata = out$strata
  )

  simulated_response <- integer(n)
  rows_by_stratum <- split(seq_len(n), out$strata)

  for (stratum_name in names(rows_by_stratum)) {
    rows <- rows_by_stratum[[stratum_name]]
    total_cases <- stratum_totals[stratum_name]

    if (total_cases == 0L) {
      next
    }

    eta_stratum <- eta[rows]
    weights <- exp(eta_stratum - max(eta_stratum))
    probabilities <- weights / sum(weights)

    simulated_response[rows] <- as.integer(rmultinom(
      n = 1,
      size = total_cases,
      prob = probabilities
    ))
  }

  out$dailymort_pulm_nonsenior <- simulated_response
  out
}

evaluate_casecrossover_effect <- function(effect_fun, x, effect_name, n) {
  if (is.null(effect_fun)) {
    return(numeric(n))
  }

  value <- effect_fun(x)

  if (!is.numeric(value)) {
    stop("`", effect_name, "` must return a numeric vector.", call. = FALSE)
  }

  value_length <- length(value)
  if (!value_length %in% c(1L, n)) {
    stop(
      "`",
      effect_name,
      "` must return a numeric vector of length 1 or nrow(data).",
      call. = FALSE
    )
  }

  value <- as.numeric(value)
  if (value_length == 1L) {
    value <- rep(value, n)
  }

  value
}

resolve_casecrossover_stratum_totals <- function(stratum_total_cases, response, strata) {
  strata_names <- names(tapply(response, strata, length))

  if (is.null(stratum_total_cases)) {
    stratum_totals <- tapply(response, strata, sum, na.rm = TRUE)
  } else {
    if (!is.numeric(stratum_total_cases)) {
      stop("`stratum_total_cases` must be NULL or numeric.", call. = FALSE)
    }

    if (length(stratum_total_cases) == 1L) {
      stratum_totals <- rep(stratum_total_cases, length(strata_names))
      names(stratum_totals) <- strata_names
    } else {
      if (is.null(names(stratum_total_cases)) || any(names(stratum_total_cases) == "")) {
        stop(
          "`stratum_total_cases` must be named by strata when it has length greater than 1.",
          call. = FALSE
        )
      }
      if (anyDuplicated(names(stratum_total_cases)) > 0) {
        stop("`stratum_total_cases` must not contain duplicated strata names.", call. = FALSE)
      }

      missing_strata <- setdiff(strata_names, names(stratum_total_cases))
      if (length(missing_strata) > 0) {
        stop(
          "`stratum_total_cases` is missing strata: ",
          paste(utils::head(missing_strata, 10), collapse = ", "),
          if (length(missing_strata) > 10) ", ..." else "",
          call. = FALSE
        )
      }

      stratum_totals <- stratum_total_cases[strata_names]
    }
  }

  if (any(!is.finite(stratum_totals))) {
    stop("Per-stratum case totals must be finite.", call. = FALSE)
  }
  if (any(stratum_totals < 0)) {
    stop("Per-stratum case totals must be nonnegative.", call. = FALSE)
  }
  if (any(abs(stratum_totals - round(stratum_totals)) > sqrt(.Machine$double.eps))) {
    stop("Per-stratum case totals must be whole numbers.", call. = FALSE)
  }

  stratum_total_names <- names(stratum_totals)
  stratum_totals <- as.integer(round(stratum_totals))
  names(stratum_totals) <- stratum_total_names
  stratum_totals
}
