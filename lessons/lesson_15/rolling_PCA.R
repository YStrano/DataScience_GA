library(readr)
library(dplyr)
library(xts)

## Set working directory
setwd("~/ga/repos/lesson-15")

## Read in data
df = read_csv('financial_indicators2.csv', na = "#N/A")

# Exclude Nulls
df <- df[complete.cases(df),]

#Converto to XTS and Scale
df_xts <- as.xts(df %>% 
                   select(-DATE) %>% 
                   scale(center=TRUE, scale=TRUE), 
                 order.by = df$DATE)

## Function to extract the rolling variance explained by the first PC
roll_var<-function(x){
  output<-prcomp(x)$sdev^2
  return(output[1]/sum(output))
}

## Run the function
rolling_var<-rollapply(df_xts, 90, roll_var, by.column=FALSE)

## Convert to df for  plotting
plotting_df <- tbl_df(data.frame(date=index(rolling_var), var = coredata(rolling_var)))

## Plot
ggplot(plotting_df, aes(x=date, y=var)) + 
  geom_line() + 
  theme_bw() + 
  ggtitle('90 Day Rolling Variance Explained')
