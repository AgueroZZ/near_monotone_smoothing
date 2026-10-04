#!/usr/bin/env Rscript

old_wd <- getwd()
on.exit(setwd(old_wd), add = TRUE)

setwd("analysis")
rmarkdown::render_site(encoding = "UTF-8")
