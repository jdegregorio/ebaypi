
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ebaypi

## Overview

ebaypi is a wrapper package for the eBay Developer API. It helps
streamline the import of listing information from active and completed
eBay listings.

The core functionality focuses on the “Finding API” which is for
importing listing information:

  - `search_ebay()` import data for active or completed listings from
    eBay

This package requires that the user has an eBay Developers account and
an eBay AppId (token). Go to the [eBay
Developer](https://developer.ebay.com/) page to sign up for an account.

## Installation

Install the package directly from GitHub:

``` r
# install.packages("devtools")
devtools::install_github("jdegregorio/ebaypi")
```

## Usage

``` r
# library(ebaypi)
# 
# # Set token
# set_ebay_token(keyring::key_get("ebay_api"))
# 
# # Make a search
# df.items <- search_ebay(
#   "babe ruth baseball card",
#   type = "completed",
#   item_filters = list(
#     MinPrice = 50,
#     MaxPrice = 10000
#   )
# )
# 
# tidyr::pivot_longer(df.items[1,], -rank, names_to = "attribute", values_to = "value")
```

## API Documentation
