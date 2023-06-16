STATA_PATH <- "/usr/local/stata15/stata-mp"

do_file_target <- function(do_file, 
                           ...,
                           .outputs,
                           .stata_path = STATA_PATH,
                           .remove_log = TRUE) {
  
  stata_args <- list(...) %>% 
    unlist() %>% 
    imap_chr(\(x, idx) paste0(idx, "=", x)) %>%
    str_flatten(" ")
  
  cmd <- paste(.stata_path, "-b do", do_file, stata_args)
  system(cmd)
  
  if (.remove_log) {
    file.remove(paste0(file_path_sans_ext(basename(do_file)), ".log"))
  }
  
  .outputs
}

