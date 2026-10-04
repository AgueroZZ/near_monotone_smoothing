# Run from the workflowr project root with OPENBLAS_NUM_THREADS=1.
library(tidyverse)
library(Matrix)
devtools::load_all("BayesGP", quiet = TRUE)

# Independent PSD formulas for the square-root processes used by these pages.
square_root_psd <- function(model, sd, reference, c_shift = 1){
  if(model == "mgp"){
    variance <- integrate(function(s){
      (2 * sqrt(s + c_shift) *
         (sqrt(5 + c_shift) - sqrt(s + c_shift)))^2
    }, lower = 0, upper = 5, rel.tol = 1e-12)$value
    return(sd * sqrt(variance))
  }
  transformed_h <- 2 * sqrt(reference + c_shift) *
    (sqrt(5 + c_shift) - sqrt(c_shift))
  sd * sqrt(transformed_h^3 / 3)
}

check_notebook <- function(path){
  # Include eval=FALSE chunks in the parse, so their full-run arguments are checked.
  code <- character()
  in_chunk <- FALSE
  for(line in readLines(path)){
    if(grepl("^```\\{r", line)){
      in_chunk <- TRUE
    } else if(grepl("^```", line)){
      in_chunk <- FALSE
    } else if(in_chunk){
      code <- c(code, line)
    }
  }
  expressions <- parse(text = code)
  env <- new.env(parent = globalenv())

  # Evaluate the real setup and helpers without loading caches or running B=1000.
  setup_names <- c("c", "B", "n", "true_psd", "sd_noise")
  for(expr in expressions){
    if(!is.call(expr) || !identical(expr[[1]], as.name("<-"))) next
    if(as.character(expr[[2]]) %in% setup_names ||
       (is.call(expr[[3]]) && identical(expr[[3]][[1]], as.name("function")))){
      eval(expr, envir = env)
    }
  }
  stopifnot(identical(env$true_psd, 2))

  # Check arguments from the disabled full-run chunks, before any fit is made.
  full_runs <- Filter(function(expr){
    is.call(expr) && identical(expr[[1]], as.name("<-")) &&
      identical(expr[[2]], as.name("all_result"))
  }, as.list(expressions))
  stopifnot(length(full_runs) == 2)
  for(expr in full_runs){
    args <- lapply(as.list(expr[[3]])[-1], eval, envir = env)
    stopifnot(args$B == 1000, args$n == env$n,
              args$u_mgp == 2, args$u_tiwp2 == 2, args$psd_fun == 2)
  }

  env$mGP_sim <- function(...){
    args <- list(...)
    env$generated_sd <- args$sd
    getFromNamespace("mGP_sim", "BayesGP")(...)
  }
  env$simulate_tiwp_boxcox <- function(...){
    args <- list(...)
    stopifnot(isTRUE(args$normalized_transform))
    env$generated_sd <- args$sd
    getFromNamespace("simulate_tiwp_boxcox", "BayesGP")(...)
  }

  rows <- list()
  for(scenario in c("A", "B")){
    set.seed(123)
    generator <- if(scenario == "A") env$sim_data_once else env$sim_data_once_B
    true_model <- if(scenario == "A") "mgp" else "tiwp2"
    data_sim <- generator(n = env$n, sd_noise = env$sd_noise,
                          psd_fun = env$true_psd)
    generated_psd <- square_root_psd(true_model, env$generated_sd,
                                     reference = 0, c_shift = env$c)
    stopifnot(abs(generated_psd - 2) < 1e-10)
    observed_max <- formals(env$replicate_comparison_B_times)$observed_max
    data_train <- filter(data_sim, x <= observed_max)

    for(model in c("mgp", "tiwp2")){
      fit <- env$fit_nearmonotone_model(
        data_train, data_sim, model_name = model, prior_psd = env$true_psd
      )
      instance <- fit$instances[[1]]
      stopifnot(abs(instance@initial_location - 20 / env$n) < 1e-12,
                instance@psd.prior$param$alpha == 0.5,
                instance@psd.prior$param$u == 2,
                instance@psd.prior$h == 5, instance@psd.prior$x == 0)
      prior_psd <- square_root_psd(model, instance@sd.prior$param$u,
                                   instance@initial_location, env$c)
      stopifnot(abs(prior_psd - 2) < 1e-10)

      metrics <- env$evaluate_model_once(data_train, data_sim, fit)
      for(part in c("data_inter", "data_pred")){
        stopifnot(nrow(metrics[[part]]) == 1,
                  all(is.finite(as.matrix(metrics[[part]]))))
      }
      rows[[length(rows) + 1]] <- data.frame(
        page = basename(path), scenario = scenario, fitted_model = model,
        n = env$n, reference = instance@initial_location,
        generated_psd = generated_psd, prior_psd_median = prior_psd
      )
      cat("Checked", basename(path), scenario, model, "\n")
      flush.console()
    }
  }
  bind_rows(rows)
}

results <- bind_rows(lapply(
  c("analysis/simulation1.rmd", "analysis/simulation2.rmd"), check_notebook
))
print(results)
cat("All simulation PSD calibration and prediction checks passed.\n")
