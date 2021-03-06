library("rstudioapi")
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))

library("ggplot2")
library("cowplot")
library("ggrepel")
library("readxl")
library("plyr")
library("RColorBrewer")




##### reading data #####

#creating data frame
data <- data.frame(primary=c(),
                   secondary=c(),
                   people=c(),
                   percent=c(),
                   integralPercent=c(),
                   subject=c())

#creating a vector of subjects
subjects <- c('Geography', 'Sociology',
              'Math', 'Physics',
              'History', 'Biology', 
              'Literature', 'CompSci', 
              'Russian', 'English',
              'German', 'French',
              'Spanish', 'Chemistry')

#creating a vector of passing grades
passingGrade <- c(35, 39,
                  21, 34,
                  31, 36,
                  29, 41,
                  36, 20,
                  20, 20,
                  20, 33)

# reading from file
for(i in 1:length(subjects)){
  data_temp <- read_excel(file.path('data', 'Book1.xls'), sheet = i, skip=1)
  data_temp$subject <- subjects[i]
  colnames(data_temp) <- c('primary', 'secondary', 'people', 'percent', 'integral', 'subject')
  data <- rbind(data, data_temp)
}

#making sure colnames are in check after merging data
colnames(data) <- c('primary', 'secondary', 'people', 'percent', 'integral', 'subject')
rm(data_temp)

#checking if the grade is passing or not
data$passing <- TRUE

for (i in 1:length(subjects)){
  data[data$subject == subjects[i],]$passing <- data[data$subject == subjects[i],]$secondary >= passingGrade[i] 
}

data$passing2 <- ''
data[data$passing == TRUE,]$passing2 <- 'passed'
data[data$passing == FALSE,]$passing2 <- 'failed'


data$passing2 <- as.factor(data$passing2)
data$subject <- as.factor(data$subject)
data$people <- as.numeric(gsub(' ', '', as.character(data$people)))
data$primary <- as.numeric(as.character(data$primary))
data$secondary <- as.numeric(as.character(data$secondary))




##### plotting primary to secondary #####

plotdots<- ggplot(data, aes(x=primary, y=secondary, col=passing2)) +
  geom_point() +
  scale_y_continuous(breaks=c(20,40,60,80,100)) +
  ggtitle("Primary to secondary grade conversion for Russian State Exam 2010")+
  xlab("Primary Grade")+
  ylab("Secondary Grade (0-100)")+
  facet_wrap( ~ subject, ncol=4) +
  scale_color_brewer(palette = "Set1")

png(file='PrimaryToSecondary2010.png', width=800, height=600)
print(plotdots +
        theme_half_open() +
        background_grid() +
        theme(legend.title=element_blank()))
dev.off()





##### plotting participants distribution #####
plots <- ggplot(data, aes(x=secondary, y=percent, col=passing2))+
  geom_point()+
  geom_line()+
  facet_wrap( ~ subject, ncol=4) +
  xlab("Secondary Grade (0-100)")+
  ylab("Participants (%)")+ 
  ggtitle("Distribution of grades for Russian State Exam 2010 (??.??.??)") +
  scale_color_brewer(palette = "Set1")

#outputting data into file
png(file='ExamDistribution2010.png', width=800, height=600)
plots +
  theme_half_open() +
  background_grid() +
  theme(legend.title=element_blank())
dev.off()





##### plotting number of participants for each subject #####
#making a summary
participantSummary <- ddply(data, .(subject, passing2), 
                            summarize, 
                            numbers = sum(people))
#second summary for total numbers of people
participantSummary2 <- ddply(data, .(subject), 
                             summarize, 
                             numbers = sum(people))

#separating summary into passing and failing
participantSummaryPassed <- participantSummary[participantSummary$passing2 == 'passed',]
participantSummaryFailed <- participantSummary[participantSummary$passing2 == 'failed',]

#ordering both by the total number of people who took the exam
participantSummaryPassed$subject <- factor(participantSummaryPassed$subject,
                                           levels = participantSummaryPassed$subject[order(-participantSummary2$numbers)])
participantSummaryFailed$subject <- factor(participantSummaryFailed$subject,
                                           levels = participantSummaryFailed$subject[order(-participantSummary2$numbers)])
#combining them back together
participantSummary <- rbind(participantSummaryPassed, participantSummaryFailed)

rm(participantSummary2, participantSummaryPassed, participantSummaryFailed)

#plotting summary
plotSummary <- ggplot(participantSummary, aes(x=subject, y=numbers, fill=passing2))+
  geom_col()+
  ggtitle("Numbers of participants for different subjects in Russian State Exam 2010 (??.??.??)")+
  ylab("Number of people")+ 
  theme(axis.title.x = element_blank(),
        legend.title=element_blank()) +
  scale_fill_brewer(palette = "Set1")

#outputting data into files

png(file='ExamSubjectSummary2010.png', width=800, height=600)
plotSummary +
  theme_half_open() +
  background_grid() +
  theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
        axis.title.x = element_blank(),
        legend.title=element_blank())
dev.off()