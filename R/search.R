
# # Dev variables
# keywords <- "marx ho scale train set"
# type <- "active"
# search_description <- TRUE
# categories <- NULL
# n_results <- 150
# item_filters <- list(MinPrice = 50, MaxPrice = 1000)
# token <- get_ebay_token()



#' Search eBay Listings
#'
#' @param keywords a character string, containing keywords for ebay listings search
#'
#' @param type a character string, either "active" or "completed" to indicate
#'     the type of listings to search.  Defaults to "active".
#'
#' @param search_description logical, set to TRUE to include sub-titles and
#'     item descriptions in the search. If FALSE, the search will only look
#'     at titles of items.
#'
#' @param categories character (or numeric) vector (max length = 3), containing
#'     the categories to include in search.
#'
#' @param item_filters a named list, containing and adhering to the conventions
#'     specified in the eBay API documention.
#'     \href{https://developer.ebay.com/Devzone/finding/CallRef/types/ItemFilterType.html}{ItemFilter Documentation}
#'
#' @param token eBay Devleoper API token (AppID)
#' @param n_results numeric (length 1), the number of listing results to return.
#'     Rounded to the nearest 100.
#'
#' @return dataframe, containing eBay search results
#' @export
#'
#' @importFrom magrittr %>%
#'
#' @examples
#' df.items <- search_ebay(
#'   "model train",
#'   type = "active",
#'   item_filters = list(MinPrice = 100, MaxPrice = 300)
#' )
search_ebay <- function(keywords,
                        type = c("active", "completed"),
                        search_description = TRUE,
                        categories = NULL,
                        item_filters = NULL,
                        n_results = 100,
                        token = get_ebay_token()) {

  # CHECK ARGUMENTS ----------------------------------------------------------

  # Check argument:  keywords
  if (missing(keywords)) stop("Missing required argument: keywords", call. = FALSE)
  if (class(keywords) != "character") stop('Incorrect argument type. Argument "keywords" must be of class "character"', call. = FALSE)
  if (length(keywords) > 1) stop("Keywords must be a character vector of length 1.", call. = FALSE)
  if (stringr::str_length(keywords) < 2) stop("Keywords must contain a minimum of two characters.", call. = FALSE)
  if (stringr::str_length(keywords) > 350) stop("Keyword input has a maximum input of 350 characters.", call. = FALSE)

  # Check argument - type
  if (length(type) > 1) warning('Search type not specified.  Defaulting search to "active" listings.', call. = FALSE)
  type <- match.arg(type)  # match argument, set default if needed

  # Check argument - search_description
  if (class(search_description) != "logical") stop('Incorrect argument type. Argument "search_description" must be of class "logical"', call. = FALSE)

  # Check argument - categories
  if(!is.null(categories)){
    if (! (class(categories) %in% c("numeric", "character")))  stop('Incorrect argument type. Argument "categories" must be of class "numeric" or "character"', call. = FALSE)
    if (length(categories) > 3) {
      warning("Category search is limited to maximum of three categories. Only the first three elements will be used.", call. = FALSE)
      categories <- categories[1:3]
    }
  }

  # Check argument - item_filters
  if (!missing(item_filters) & class(item_filters) != "list") stop('Incorrect argument type. Argument "item_filters" must be of class "list"', call. = FALSE)

  # Check argument:  n_results
  if (class(n_results) != "numeric") stop('Incorrect argument type. Argument "n_results" must be of class "numeric"', call. = FALSE)
  if (length(n_results) > 1) stop("n_results must be a numeric value of length 1.", call. = FALSE)
  if (n_results < 1) stop("n_results must be a positive value.")
  if (n_results > 10000) {
    message("Maximum results limit of 10,000 exceeded. Returning 10,000 results.")
    n_results <- 10000
  }
  if (n_results %% 100 != 0) message("The specified n_results is not divisible by 100, rounding to nearest 100")


  # Check argument:  token
  if (class(keywords) != "character") stop('Incorrect argument type. Argument "token" must be of class "character"', call. = FALSE)
  if (length(keywords) == 0) stop("Invalid or missing token.  Use set_ebay_token(token) to set your eBay token to an environmental variable.", call. = FALSE)


  # BUILD QUERY ---------------------------------------------------------------

  # Initialize query list
  query <- list()

  # Build query - keywords
  query <- append(query, list("keywords" = keywords))

  # Build query - search_description (convert to string)
  search_description <- stringr::str_to_lower(search_description)
  query <- append(query, list("descriptionSearch" = search_description))

  # Build query - categories
  if (!is.null(categories)) {
    for (i in 1:length(categories)) {
      tmp.list <- list(categories[[i]])
      names(tmp.list) <- stringr::str_c("categoryId(", i-1, ")")
      query <- append(query, tmp.list)
    }
  }

  # Build query - item_filters
  if (!is.null(item_filters)) {
    for (i in 1:length(item_filters)) {

      # Extract filter name/value pair
      tmp.list <- list(
        names(item_filters)[[i]],
        item_filters[[i]]
      )

      # Name item_filters
      names(tmp.list) <- c(
        stringr::str_c("itemFilter(", i-1, ").name"),
        stringr::str_c("itemFilter(", i-1, ").value")
      )

      # Add to query
      query <- append(query, tmp.list)
    }
  }


  # FINAL PROCESSING FOR API CALL ---------------------------------------------

  # Determine number of pages (i.e. # of calls required for n_results)
  if(n_results %% 100 == 0) {
    n_pages <- n_results / 100
  } else {
    n_pages <- n_results %/% 100 + 1
  }

  # Set operation type for API call
  operation <- dplyr::case_when(
    type == "active" ~ "findItemsAdvanced",
    type == "completed" ~ "findCompletedItems"
  )


  # CALL API - GATHER RESULTS -------------------------------------------------

  # Initialize item list
  xml.items <- list()

  # Loop through pages
  for (page in 1:n_pages){

    # Call the API
    resp <- httr::GET(
      url = stringr::str_c("http://svcs.ebay.com/services/search/FindingService/v1",
                           "?",
                           "OPERATION-NAME=", operation, "&",
                           "SERVICE-VERSION=1.0.0&",
                           "RESPONSE-DATA-FORMAT=XML&",
                           "SECURITY-APPNAME=", token, "&",
                           "REST-PAYLOAD&",
                           "paginationInput.entriesPerPage=100&",
                           "paginationInput.pageNumber=", page),
      query = query
    )

    # Check for failed request
    if (httr::http_error(resp)) {
      stop( glue::glue("API request failed.  Status Code: {httr::status_code(resp)}"), call. = FALSE)
    }

    # Check XML is returned
    if (httr::http_type(resp) != "text/xml") {
      stop("API did not return XML", call. = FALSE)
    }

    # Parse the response
    xml <- xml2::read_xml(httr::content(resp, "text"))
    tmp.xml.items <- xml2::xml_find_all(xml, "//d1:item")

    # Append to total items list
    xml.items <- append(xml.items, tmp.xml.items)

    # Check length
    if (page == 1 & length(tmp.xml.items) < 100) {
      message(paste0("Only ", length(tmp.xml.items), " search results available."))
      break
    }

  }

  # Parse items into a dataframe
  df.items <-
    tibble::tibble(
      rank = 1:length(xml.items),
      xml_item = xml.items
    ) %>%
    dplyr::mutate(
      parsed = purrr::map(
        xml_item,
        ~ .x %>%
          xml2::as_list() %>%
          unlist() %>%
          tibble::enframe("attribute", "value")
      )
    ) %>%
    dplyr::select(rank, parsed) %>%
    tidyr::unnest(parsed) %>%
    dplyr::distinct() %>%
    tidyr::pivot_wider(
      id_cols = rank,
      names_from = attribute,
      values_from = value,
      values_fn = list(value = dplyr::first)
    )

  return(df.items)
}





# # Tests
# df.items <- search_ebay("train set", type = "complete", n_results = 150)
# search_ebay()
# search_ebay(234)
# search_ebay(c("train", "set"))
# search_ebay(stringr::str_c(rep("keyword", 100), collapse = " "))
# search_ebay("train set")
# search_ebay("train set", type = "z")
# search_ebay("train set", type = "active", search_description = "true")
# search_ebay("train set", type = "active", categories = c(TRUE, FALSE))
# search_ebay("train set", type = "active", categories = c(12, 24, 355, 39))
# search_ebay("train set", type = "active", categories = c(12, 24, 35))
# search_ebay("train set", type = "active", categories = c(12, 24, 35), n_results =  100000)
