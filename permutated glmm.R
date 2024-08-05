####################

# setwd before running the code

#install packages before if needed

library(readxl)
library(igraph)
library(MASS)

sparrow_df <- read_excel('sample_df.xlsx')

#filter to groups that have degree values
df_filtered <- sparrow_df[complete.cases(sparrow_df$degree),]

# factor nested variables
df_filtered$groupcage <- factor(df_filtered$groupcage)
df_filtered$bird_id <- factor(df_filtered$bird_id)
df_filtered$id_withingroup <- paste(df_filtered$groupcage, df_filtered$bird_id, sep ="")
df_filtered$id_withingroup <- factor(df_filtered$id_withingroup)

#run non-permutated model
sparrow_GLMM <- glmmPQL(degree ~ sex + status_clean + mean_mass, 
                        random = ~1 | groupcage/tail_color,
                        family = quasipoisson(), 
                        data = df_filtered)

summary(sparrow_GLMM)
summary_data <- summary(sparrow_GLMM)
#effect for sex
t_sex <- summary_data$tTable[2,4]
coef_sex <- coefficients(sparrow_GLMM)[1,2]
#effect for status
t_status <- summary_data$tTable[3,4]
coef_status <- coefficients(sparrow_GLMM)[1,3]
#effecr for mass
t_mass <- summary_data$tTable[4,4]
coef_mass <- coefficients(sparrow_GLMM)[1,4]
#effects for all variables
#coefs <- coefficients(sparrow_GLMM) 

#permutated df

permutation_results <- list()
perm_coefs_sex <- list()
perm_coefs_status <- list()
perm_coefs_mass <- list()

#number of permutations 
B <- 1000

# for each iteration permutate nodes and degrees, and run the model
for (b in 1:B) {
  print(paste("Iteration:", b))
  #permutate strength values
  degrees <- df_filtered$degree
  permutated_degrees <- sample(degrees)
  #permutate nodes within each groupcage
  df_filtered$permuted_tail_color <- unlist(with(df_filtered, ave(tail_color, groupcage, FUN = function(x) sample(x))))
  
  tryCatch({
    GLMM <- glmmPQL(permutated_degrees ~ sex + status_clean + mean_mass, 
                    random = ~1 | groupcage/permuted_tail_color,
                    family = quasipoisson(), 
                    data = df_filtered)
    perm_coefs_sex[[b]] <- coefficients(GLMM)[1,2]
    perm_coefs_status[[b]] <- coefficients(GLMM)[1,3]
    perm_coefs_mass[[b]] <- coefficients(GLMM)[1,4]
    permutation_results[[b]] <- GLMM
  }, error = function(e) {
    # Print error message
    cat("Error occurred in iteration", b, ": ", conditionMessage(e), "\n")
  })
}
#turning the list to numric for the plot
perm_coefs_sex_numeric <- unlist(perm_coefs_sex)
perm_coefs_status_numeric <- unlist(perm_coefs_status)
perm_coefs_mass_numeric <- unlist(perm_coefs_mass)

                                                                  
# Plot resulting distribution for sex coef
a <- hist(perm_coefs_sex_numeric,xlim=c(min(perm_coefs_sex_numeric),max(perm_coefs_sex_numeric)),col="black",xlab="Sex Coefficient value",ylab="Frequency",breaks=100,cex.axis=1.3,main="", tck=0.01)
segments(coef_sex,0,coef_sex,max(a$counts),col="red")
box()
text(par('usr')[1] + (par('usr')[2]-par('usr')[1])/15,par('usr')[4] - (par('usr')[4]-par('usr')[3])/15, "c)", cex=2) 

# Plot resulting distribution for status coef
a <- hist(perm_coefs_status_numeric,xlim=c(min(perm_coefs_status_numeric),max(perm_coefs_status_numeric)),col="black",xlab="Status Coefficient value",ylab="Frequency",breaks=100,cex.axis=1.3,main="", tck=0.01)
segments(coef_status,0,coef_status,max(a$counts),col="red")
box()
text(par('usr')[1] + (par('usr')[2]-par('usr')[1])/15,par('usr')[4] - (par('usr')[4]-par('usr')[3])/15, "c)", cex=2) 

# Plot resulting distribution for sex coef
a <- hist(perm_coefs_mass_numeric,xlim=c(min(perm_coefs_mass_numeric),max(perm_coefs_mass_numeric)),col="black",xlab="Mass Coefficient value",ylab="Frequency",breaks=100,cex.axis=1.3,main="", tck=0.01)
segments(coef_mass,0,coef_mass,max(a$counts),col="red")
box()
text(par('usr')[1] + (par('usr')[2]-par('usr')[1])/15,par('usr')[4] - (par('usr')[4]-par('usr')[3])/15, "c)", cex=2) 

# P values
# I used unique to get 1 value for each permutation, rather identical values for each permutated iteration. 
sum(coef_sex>unique(perm_coefs_sex_numeric))/1000
sum(coef_status>unique(perm_coefs_status_numeric))/1000
sum(coef_mass>unique(perm_coefs_mass_numeric))/1000
