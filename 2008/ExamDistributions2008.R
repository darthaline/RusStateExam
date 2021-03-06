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
subjects <- c('Russian', 'Math',
              'Physics', 'Chemistry',
              'CompSci', 'Biology',
              'History', 'Geography',
              'English', 'German',
              'French', 'Sociology', 'Literature')

#creating a vector of passing grades
passingGrade <- c(40, 25,
                  38, 36,
                  39, 35,
                  33, 35,
                  31, 31,
                  31, 39, 23)

# reading from file
for(i in 1:13){
  data_temp <- read_excel(file.path('data', 'tabl_sootv.xls'), sheet = i, skip=4)
  data_temp$subject <- subjects[i]
  data_temp <- data_temp[-dim(data_temp)[1],]
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






##### plotting primary to secondary #####

plotdots<- ggplot(data, aes(x=primary, y=secondary, col=passing2)) +
  geom_point() +
  scale_y_continuous(breaks=c(20,40,60,80,100)) +
  ggtitle("Primary to secondary grade conversion for Russian State Exam 2008")+
  xlab("Primary Grade")+
  ylab("Secondary Grade (0-100)")+
  facet_wrap( ~ subject, ncol=4) +
  scale_color_brewer(palette = "Set1")

png(file='PrimaryToSecondary2008.png', width=800, height=600)
print(plotdots +
        theme_half_open() +
        background_grid() +
        theme())
dev.off()





##### plotting participants distribution #####
plots <- ggplot(data, aes(x=secondary, y=percent, col=passing2))+
  geom_point()+
  geom_line()+
  facet_wrap( ~ subject, ncol=4) +
  xlab("Secondary Grade (0-100)")+
  ylab("Participants (%)")+ 
  ggtitle("Distribution of grades for Russian State Exam 2008 (16.06.08)") +
  scale_color_brewer(palette = "Set1")

#outputting data into files
png(file='ExamDistribution2008.png', width=800, height=600)
plots +
  theme_half_open() +
  background_grid() +
  theme()
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
  ggtitle("Numbers of participants for different subjects in Russian State Exam 2008 (16.06.08)")+
  ylab("Number of people")+ 
  theme(axis.title.x = element_blank()) +
  scale_fill_brewer(palette = "Set1")

#outputting data into files
png(file='ExamSubjectSummary2008.png', width=800, height=600)
plotSummary +
    theme_half_open() +
    background_grid() +
    theme(axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1),
          axis.title.x = element_blank())
dev.off()