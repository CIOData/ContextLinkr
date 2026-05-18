library(tidyverse)
library(tidygeocoder)
library(jsonlite)

path = 'C:\\Users\\jtburu2\\OneDrive - University of Kentucky\\Cancer Research\\ContextLinkr'
setwd(path)

df = read.csv('list_of_addresses.csv', header = T, colClasses = 'character') |>
    dplyr::mutate(
        full_address = paste0(address, ', ', city, ', ', state, ' ', zip)
    )
df1 = jsonlite::fromJSON('list_of_addresses2.json')[['addresses']]

df2 = df1 %>% 
    mutate()

### to do:
### 1) identify street, city, state, zip vs single address
### 2) normalize zip
### 3) add additional geocoders
### possible functions: gc_address(), gc_county(), gc_zip()

dat = df1 |>
    #data prep
    dplyr::rename(
        address = address1,
        city = city,
        state = state,
        zip = postalCode
    ) |>
    dplyr::mutate(
        postalcode = str_pad(zip, side = 'left', width = 5, pad = '0') #this might not be necessary
    ) |>
    #geocode
    tidygeocoder::geocode_combine(
        queries = list(
            # list(method = "census", mode = "batch"),
            # list(method = "census", mode = "single"),
            list(method = "osm")
        ),
        global_params = list(
            street = 'address',
            city = 'city',
            state = 'state',
            postalcode = 'postalcode'
        ),
        lat = latitude,
        long = longitude
    )

###add to utils
rm_quote <- function(string) gsub("\"", "", string)

###geocode addresses function
gc_address <- 
    function(
        .data,
        address = NULL, 
        street = NULL,
        city = NULL,
        state = NULL,
        zip = NULL,
        census_batch = TRUE,
        census_single = TRUE,
        osm = TRUE,
        geocodio = FALSE,
        google = FALSE,
        arcgis = FALSE,
        mapbox = FALSE
    ){
        # Non-standard evaluation --------------------------------------------------------------
        # Quote unquoted vars without double quoting quoted vars
        if (!is.null(substitute(address))) address <- rm_quote(deparse(substitute(address)))
        if (!is.null(substitute(street))) street <- rm_quote(deparse(substitute(street)))
        if (!is.null(substitute(city))) city <- rm_quote(deparse(substitute(city)))
        if (!is.null(substitute(state))) state <- rm_quote(deparse(substitute(state)))
        if (!is.null(substitute(zip))) zip <- rm_quote(deparse(substitute(zip)))
        
        if (!(is.data.frame(.data))) {
            stop(".data is not a dataframe.", call. = FALSE)
        }
        
        df_input <- as.data.frame(lapply(.data, as.character))
        
        #add geocoding services to query
        query_list <- list()
        
        if (census_batch){
            query_list[[length(query_list) + 1]] <- list(method = "census", mode = "batch")
        }
        
        if (census_single){
            query_list[[length(query_list) + 1]] <- list(method = "census", mode = "single")
        }
        
        if (osm){
            query_list[[length(query_list) + 1]] <- list(method = "osm")
        }
        
        #perform geocoding
        res <- tidygeocoder::geocode_combine(
            df_input,
            queries = query_list,
            global_params = list(
                address = address,
                street = street,
                city = city,
                state = state,
                postalcode = zip
            ),
            lat = latitude,
            long = longitude
        )
        
        chk = sum(!is.na(res[,'latitude']))/nrow(res)
        
        print(paste0('Correctly matched ', round(chk*100, 1), '% of records.'))
        
        return(res)
    }

a = gc_address(df, street = 'address', city = 'city', state = 'state', zip = 'zip')

b = gc_address(df1, street = 'address1', city = 'city', state = 'state', zip = 'postalCode')

c = gc_address(df, address = 'full_address')
