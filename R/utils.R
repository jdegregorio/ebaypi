#' Set eBay Token
#'
#' This function allows you to set and store your eBay API token as an
#'     environmental variable.
#'
#' @param token a character string, containing eBay API token.
#'
#' @export
#'
set_ebay_token <- function(token) {
  Sys.setenv("ebaypi_ebay_token" = token)
}

#' Get eBay Token
#'
#' This function returns the eBay api token stored as an environmental variable.
#'
#' @return a character string, containing the eBay API token.
#' @export
#'
get_ebay_token <- function() {
  Sys.getenv("ebaypi_ebay_token")
}
