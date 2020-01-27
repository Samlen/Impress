###################################################
#PROJECT:	  Waksio Pesticide Project
#PURPOSE: 	Neuro analysis - Bayesian Adaptive Sampling (BAS) analysis
#FILENAME:  NeuroPesticides_all outcomes
#PATH:		  "C:/Users/samue/Dropbox/1_PhD/02 Projects/20XX - Winkler_Pesticides EAWAG_Winkler/06_Uganda/11 - Data analysis/03 - stata data"
#CREATED: 	01.05.2019       
#AUTHOR:    S Fuhrimann
#DATA IN:  	Analysis_Exposure_Neuro_clean.dta
#DATA OUT: 	
#UPDATES:	  SF - 09.01.2020 update according to paper draft version 2
#NOTES:	    # 14 neuro different test scores, 298 obs, 256 complete for all neur tests
# Bayesian Adaptive Sampling for Bayesian Model Averaging and Variable Selection in Linear Models

# Content
# 1. Read in data
# 2. Create vectors with names of outcomes, covariates, and exposures
# 3. Quality control - select variable according to critiraias, i.e. exposure at least 20 observation   
# 4. imputations, creat data set for analysis
# 5. Classical regression model, each pesticide in a seperate model - continouse outcomes
# 6. False discovery rate (FDR)
# 7. plot the regession models as forest plot

###################################################
# Library
library(readxl)
library(BAS)      
library(dplyr)
library(haven) # reads stata files
library(ggplot2)
library(psych)
library(corrplot)   # correlation plots
library(pastecs)    # describtive stat
library(Amelia)     # can map missing data
library(survival)   # creat cross-tables
library(tidyr)      # reshape data set

###################################################################################
# 1. Read in data
data <- as.data.frame(read_dta(file = "../data/raw/Analysis_Exposure_Neuro_clean.dta")) 

###################################################################################
# 2. Create vectors with names of outcomes, covariates, and exposures
###################################################################################
# Outcomes
neuro_test <- data %>% select("n11PVF_c", "n12SVF_c", "n2TMT_t", "n3CT_t", "n4DVT_t", "n4DVT_m", "n5VDS_f", "n5VDS_b", "n6DST_ce", "n7aTAP_dm", "n7bTAP_ndm", "n8B_c", "n9PEG_dc", "n9PEG_ndc")
all.outcomes <- colnames(neuro_test) # 14 neuro test scores

# Co-variates
all.covariates <- c("sex","age", "edu_co", "p1ex", "dri_gr_2" )

# Exposure 
all.exposures <- colnames(data)[grepl("score_", colnames(data))]
all.exposures <- all.exposures[grepl("_year$", all.exposures)]

###################################################################################
# 3. Quality control - select variable according to critiraias, i.e. exposure at least 20 observation   
###################################################################################
selected.outcomes   <- all.outcomes
selected.covariates <- all.covariates 

# select only pesticides which were applied by at least 20 workers (9 pesticides instead of 14)
# ture / false if code is executet
selected.exposures <- unlist(lapply(all.exposures,function(curEXPO){
  if (TRUE) {
    devAskNewPage(ask=TRUE)
    hist(data[,curEXPO],main=curEXPO)
    devAskNewPage(ask=FALSE)
  }
  if (sum(data[,curEXPO]>0) < 19) {
    return(NULL)
  } else {
    return(curEXPO)
  } 
}))

###################################################################################
# 4. imputations, creat data set for analysis
###################################################################################
# 298 obs all completed cases per test!!
if (TRUE) {
  selected.data <- data[complete.cases(data[,c(selected.covariates,selected.exposures)]),c(selected.outcomes,selected.covariates,selected.exposures)]
  nrow(data)-nrow(selected.data)
  summary(selected.data)
}

###################################################################################
# 5. Classical regression model, each pesticide in a seperate model - continouse outcomes
###################################################################################
if (!FALSE) {
  glm.res <- NULL # emty data set
  for (curOUT in selected.outcomes) {
    for (curEXPO in selected.exposures) {
      formula <- paste0(curOUT," ~ ",curEXPO," + ",paste0(selected.covariates,collapse=" + "))      # paste0 cuts the characters appart and puts in the value
      m <- glm(as.formula(formula), data=selected.data)                   # model formula
      AIC <- AIC(m)                                                       # model fit
      BIC <- BIC(m)                                                       # model fit
      tmp <- summary(m)$coefficients                                      # takes out coefficients form the model
      tmp <- cbind(data.frame(OUT=curOUT,EXPO=rownames(tmp)),tmp,AIC,BIC) # specify which values to pick
      rownames(tmp) <- NULL
      tmp <- tmp[c(2,3,4,5,6,7),]                                         # specify which variables to pick
      tmp$Lower<-tmp$Estimate-qnorm(1-0.05/2)*tmp$`Std. Error`            # 95% CI
      tmp$Upper<-tmp$Estimate+qnorm(1-0.05/2)*tmp$`Std. Error`
      glm.res <- rbind(glm.res,tmp)
    }
  }
  glm.res
  df<-glm.res
}

###################################################################################
# 6. Test for False Discovery Rate
###################################################################################
fdr <- p.adjust(df$`Pr(>|t|)`,
                method="fdr")
fdr[]
range(fdr) # 5.985581e-37 9.983595e-01

# change data set into data frame
fdr.df <- as.data.frame((fdr))
fdr.df <- fdr.df[order("(fdr)"),]
hist(fdr.df$"(fdr)")

###################################################################################
# 7. plot the regession models as forest plot
###################################################################################
# Changing order and names of the models
df$OUT <- factor(df$OUT,levels=c("n12SVF_c", "n11PVF_c", "n3CT_t", "n5VDS_b",	"n8B_c", "n5VDS_f",		
                                "n2TMT_t", "n6DST_ce",	"n4DVT_t",	"n4DVT_m",		
                                "n9PEG_dc", "n9PEG_ndc", "n7aTAP_dm", "n7bTAP_ndm"),
                        labels=c("Lan-Sem","Lan-Pho","Exe-Col-t","Exe-Ver-b","Ler-Ben-f","Ler-Ver-f",
                                "Com-Tra-t","Com-Dig-s","Com-Dig-v-t","Com-Dig-v-6",
                                "Mot-Peg-d","Mot-Peg-nd","Mot-Tap-d","Mot-Tap-nd"))
levels(df$OUT)

write.csv(df, file =  "C:/Users/samue/Dropbox/1_PhD/02 Projects/20XX - Winkler_Pesticides EAWAG_Winkler/06_Uganda/11 - Data analysis/05 - results/reg.ug.298.cont.csv")

df_beta <- df %>% select("OUT", "EXPO", "Estimate")
df_beta_w <- df_beta %>% spread(OUT, EXPO)    

# Forest plot
png("C:/Users/samue/Dropbox/1_PhD/02 Projects/20XX - Winkler_Pesticides EAWAG_Winkler/06_Uganda/11 - Data analysis/05 - results/forest_out.png",height=15,width=10,unit="in",res=300)
ggplot(df,aes(OUT,Estimate))+
  geom_point(size=3)+
  geom_errorbar(aes(ymin=Lower,ymax=Upper),width=0.2,lwd=1.1)+
  facet_wrap(~EXPO,scales="free")+     # all models together
  coord_flip()+                        # flip the x and y axis
  #coord_flip(ylim=c(-2,2))+
  geom_hline(yintercept=0, lty=2) +    # add a dotted line at x=0 after flip
  xlab(label="Neurocognetive outcome")+ylab(label="Exposure Score")+
  labs(title="Model",
       subtitle="Cont.- n249")
dev.off()









