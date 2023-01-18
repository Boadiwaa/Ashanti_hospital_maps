library(tidyverse)
library(rvest)
library(stringr)
library(rebus)
library(rlist)
library(writexl)

# Creating a function to scrape the contact details from the webpage
get_contact <- function(html){
  
  pages_data <- html %>% 
    html_nodes('.fdtails_home') %>% 
    html_text(trim = TRUE)
  pattern = 'Tel: '%R% capture(DIGIT)
   str_extract(pages_data, "Tel:\\s\\s[0-9]+\\S+")
}


page <- read_html('http://www.ghanahospitals.org/regions/regionlist.php?sel=ownership&page=government&r=ashanti')

#These lines of code extracts the ids and hospital names and put them in a dataframe
b <- page %>% html_nodes('.listing') %>% html_nodes("[href^=fdetails]")

id <- str_extract(b, "id=[0-9]+")
names <-str_extract(b, ">+.+")

result <- data.frame(id,names)

#These lines of code creates a list of new urls based on the ids so each webpage on the list can be visited and extracted from
phrase1 <- 'http://www.ghanahospitals.org/regions/fdetails.php?'
phrase2 <- '&r=ashanti' 

new_list <- list()

for(i in result$id){
  new_url <- str_c(phrase1,id,phrase2)
  url_list <- as.list(new_url)
}

#These lines of code extract the contact number using the function created earlier on, and appends them to the dataframe created.
for (u in url_list) {
  address<- read_html(u)
  contact <- get_contact(address)
  new_list <- list.append(new_list,contact)
}

result$contacts <- unlist(new_list)

#saving into an excel workbook
write_xlsx(result, "C:\\Users\\pauli\\Desktop\\sncode\\contacts.xlsx")
