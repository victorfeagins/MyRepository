################ 


#Input url folder location that contains rowdylink attendance files
folder <- "https://drive.google.com/drive/u/0/folders/1yuEXjuImTygnMm7O52tKH1AxIRs-Ky3Z"


#Output 
name <- "Spring2021AttendencePoints" #name of the file to be saved
location <- "https://drive.google.com/drive/u/0/folders/1OOjnY3HSlZKKoNp2RgVc46S3zx0gmoVr" #url of folder to place the new file

#Options
type <-  "spreadsheet" #The file will be saved as a google spread sheet


############# Code 
#Libraries used in code
library("googledrive")
library("readxl")
library("stringr")
library("dplyr")

###### Authenticate google account look at the console to sign in or use cached permisson
drive_auth() 


#Google Drive gets all the files in the folder
eventfolder <- drive_get(folder) 

#Gets the individual files in the folder
files <- drive_ls(eventfolder)

#Counts how many files there are
numberfiles <- nrow(files)

#Creates a list of file names to be called when downloading the files from the drive
filenames <- str_c("event", as.character(1:numberfiles), ".xlsx")

#For every file Google Drive downloads to working directory
for (i in 1:numberfiles){
  drive_download(files[i,], path = filenames[i] , overwrite = T)
}

#Skips the first 6 rows to start reading in all the files assumes all the files are the same format of rowdylink attendance
dflist <- lapply(filenames, read_excel, skip= 6) 


#Data Processing
alldata<- bind_rows(dflist, .id = "column_label") #combines all the event data into one dataframe

attendnum <- data.frame(table(alldata["Card ID Number"])) #creates a dataframe by abc123 and how many attended events

lookuptable <- alldata %>% #Gets the unique name, email for everyone attended the events 
  select("Card ID Number","First Name", "Last Name", "Campus Email") %>% 
  filter(!duplicated(.$`Card ID Number`)) 



#Creates Final Data
finaldata <- merge(lookuptable, attendnum, by.x = "Card ID Number", by.y = "Var1") 

#Saves finaldata to working directory
write.csv(finaldata, file = "finaldata.csv")


#Uploads final data to drive
drive_put("finaldata.csv", path = location,
          name = name, type = type)




