
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
library(ebaypi)

# Set token
set_ebay_token(keyring::key_get("ebay_api"))

# Make a search
df.items <- search_ebay(
  "babe ruth baseball card",
  type = "completed",
  item_filters = list(
    MinPrice = 50,
    MaxPrice = 10000
  )
)

tidyr::pivot_longer(df.items[1,], -rank, names_to = "attribute", values_to = "value")
#> # A tibble: 42 x 3
#>     rank attribute                value                                    
#>    <int> <chr>                    <chr>                                    
#>  1     1 itemId                   163882681803                             
#>  2     1 title                    1959 Fleer #2 Ted Williams (w/Ted's Idol~
#>  3     1 globalId                 EBAY-US                                  
#>  4     1 primaryCategory.categor~ 213                                      
#>  5     1 primaryCategory.categor~ Baseball Cards                           
#>  6     1 galleryURL               https://thumbs4.ebaystatic.com/m/m5x9VEX~
#>  7     1 viewItemURL              https://www.ebay.com/itm/1959-Fleer-2-Te~
#>  8     1 paymentMethod            PayPal                                   
#>  9     1 autoPay                  false                                    
#> 10     1 postalCode               907**                                    
#> 11     1 location                 Cerritos,CA,USA                          
#> 12     1 country                  US                                       
#> 13     1 shippingInfo.shippingSe~ 0.0                                      
#> 14     1 shippingInfo.shippingTy~ Free                                     
#> 15     1 shippingInfo.shipToLoca~ Worldwide                                
#> 16     1 shippingInfo.expeditedS~ false                                    
#> 17     1 shippingInfo.oneDayShip~ false                                    
#> 18     1 shippingInfo.handlingTi~ 1                                        
#> 19     1 sellingStatus.currentPr~ 184.95                                   
#> 20     1 sellingStatus.converted~ 184.95                                   
#> 21     1 sellingStatus.sellingSt~ EndedWithSales                           
#> 22     1 listingInfo.bestOfferEn~ true                                     
#> 23     1 listingInfo.buyItNowAva~ false                                    
#> 24     1 listingInfo.startTime    2019-09-28T06:53:10.000Z                 
#> 25     1 listingInfo.endTime      2019-11-10T21:20:42.000Z                 
#> 26     1 listingInfo.listingType  StoreInventory                           
#> 27     1 listingInfo.gift         false                                    
#> 28     1 listingInfo.watchCount   1                                        
#> 29     1 returnsAccepted          true                                     
#> 30     1 condition.conditionId    2750                                     
#> 31     1 condition.conditionDisp~ Like New                                 
#> 32     1 isMultiVariationListing  false                                    
#> 33     1 topRatedListing          true                                     
#> 34     1 sellingStatus.bidCount   <NA>                                     
#> 35     1 listingInfo.buyItNowPri~ <NA>                                     
#> 36     1 listingInfo.convertedBu~ <NA>                                     
#> 37     1 productId                <NA>                                     
#> 38     1 charityId                <NA>                                     
#> 39     1 subtitle                 <NA>                                     
#> 40     1 secondaryCategory.categ~ <NA>                                     
#> 41     1 secondaryCategory.categ~ <NA>                                     
#> 42     1 galleryPlusPictureURL    <NA>
```

## API Documentation

For complete API documention, please see the [eBay Developer API
Webpage](https://developer.ebay.com/docs).
