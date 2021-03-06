# Inter-speaker Correlations for American data

# Performs Pearson's product-moment correlations between principal component p 
# of each speaker with all other speakers.
# Also outputs variances accounted for by major PCs.

# Written by Jenny Sahng
# 14/09/2016

source('~/Part IV Project/R code/Story (2005)/readAreaFunctions_Story.R', echo=TRUE)
AmE <- read.Story.data()
numVTs <- AmE$numVTs
VTlist <- AmE$VTlist
allAmE.df <- AmE$data

# The VT and vowel number to skip in correlations if it's missing (SM2 herd)
VT.skip <- "SM2"
Vowel.skip <- "herd"

# Principal components to analyse
p.max <- 3

# Table of variances
vars <- matrix(data = NA, nrow = numVTs, ncol = p.max+2, byrow = TRUE)
colnames(vars) <- c("PC1+PC2", paste("PC", 1:p.max, sep=""), "Total")
rownames(vars) <- VTlist

table <- NA

for (p in 1:p.max) {
  
  # Initialise tables
  corr <- matrix(data = NA, nrow = numVTs-1, ncol = numVTs-1, byrow = TRUE)
  colnames(corr) <- VTlist[-1]
  rownames(corr) <- VTlist[-numVTs]
  
  pvalues <- matrix(data = NA, nrow = numVTs-1, ncol = numVTs-1, byrow = TRUE)
  colnames(pvalues) <- VTlist[-1]
  rownames(pvalues) <- VTlist[-numVTs]
  
  namerow <- matrix(data = NA, nrow = 1, ncol = numVTs-1, byrow = TRUE)
  namerow[1] <- paste("PC", p, sep="")
  
  namerowabs <- matrix(data = NA, nrow = 1, ncol = numVTs-1, byrow = TRUE)
  namerowabs[1] <- paste("PC", p, " absolute values", sep="")
  
  prow <- matrix(data = NA, nrow = 1, ncol = numVTs-1, byrow = TRUE)
  prow[1] <- paste("PC", p, " p-values", sep="")
  
  for(i in 1:numVTs) {
    
    j <- i + 1

    while(j <= numVTs) {
      
      m <- ((i-1)*10 + i):(i*10 + i)
      n <- ((j-1)*10 + j):(j*10 + j)
      
      # Skip herd if comparing with SM2 since it doesn't have it.
      if ( (VTlist[i] == VT.skip ) | (VTlist[j] == VT.skip) ) {
        m <- m[-4]
        n <- n[-4]
      }
      
      # PCA
      pca1 <- prcomp(~., data = allAmE.df[m, -(1:2)], scale=T)
      pca2 <- prcomp(~., data = allAmE.df[n, -(1:2)], scale=T) 
      
      # Interspeaker correlations
      cor <- cor.test(unname(pca1$x[,p]), unname(pca2$x[,p]))
      
      # Write to tables
      corr[i,j-1] <- unname(cor$estimate)
      pvalues[i,j-1] <- unname(cor$p.value)
      
      j <- j + 1
    }
    
  }
  
  # Append correlation tables to file
  table <- rbind(table, rbind(namerow, corr, namerowabs, abs(corr), prow, pvalues))
}

# Write table to file
write.csv(table, file = "AmE_corr_inter.csv")

# Variances

for(i in 1:numVTs) {

  pca <- prcomp(~., data = allAmE.df[((i-1)*10 + i):(i*10 + i), -(1:2)], scale=T)
  vars[i,1] <- summary(pca)$importance[2,1] + summary(pca)$importance[2,2]
  vars[i,-c(1,p.max+2)] <- unname(summary(pca)$importance[2,1:p.max])
  vars[i,p.max+2] <- summary(pca)$importance[2,1] + summary(pca)$importance[2,2] + summary(pca)$importance[2,3]
  write.csv(vars, file = "AmE_vars.csv")
  
}

# Plot calculated variances and variances from Story
plot(100*vars[,p.max+2], col="red", ylim=c(85,100))
par(new=T)
points(c(92.8,90.5,94.7,93,92.6,97.3))

