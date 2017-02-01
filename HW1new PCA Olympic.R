##############################################
## HW1new - PCA of Olympic performance data ##
##############################################
# load libraries
library(ggplot2); library(factoextra)

# load data
setwd('C:/Users/mit_7_000/Downloads')
getwd()
oly <- read.table('olympic2.txt', header = TRUE, sep = '') # data.frame
n <- 34 # no. of individuals

# compute mean-centred variables
centre_apply <- function(x) {
  apply(x, 2, function(y) y - mean(y))
}
oly_centre <- centre_apply(oly) # matrix

# compute SD of mean-centred variables
sd_apply <- function(x) {
  apply(x, 2, function(y) sd(y))
}
oly_sd <- sd_apply(as.data.frame(oly_centre)) # vector or numeric

# standardise mean-centred variables with the computed SD vector
oly_renorm <- sweep(oly_centre, 2, oly_sd, "/") # matrix

# PCA with standardised variables
## poddhyoti1
pca_oly <- princomp(oly_renorm, scores = TRUE)
pca_sum <- summary(pca_oly)
## poddhyoti2 = poddhyoti1
pca_oly2 <- prcomp(oly_renorm, scale = TRUE)
pca_sum2 <- summary(pca_oly)

# comparison of 2 computations
(1 / n)*(t(oly_renorm) %*% oly_renorm) # corrected var-covar matrix on standardised vars
((n - 1) / n)*cov(oly_renorm) # corrected var-covar matrix on standardised vars

# plot PCA1 vs PCA2
plot(pca_oly$scores[, 1], pca_oly$scores[, 2], xlab = 'Comp1', ylab = 'Comp2', type = 'n')
abline(h = 0, v = 0)
text(pca_oly$scores[, 1], pca_oly$scores[, 2], xlab = 'Comp1', ylab = 'Comp2', labels = 1:34)
title(main = 'PCA1 vs. PCA2')

# correlation between PCA comp.1 scores and 100_mt original standardised scores
cor(oly_renorm[, 1], pca_oly$scores[, 1])
# correlation between PCA scores and 100_mt original standardised scores
cor(oly_renorm[, 1], pca_oly$scores)
# correlation between PCA comp.1 scores and original standardised scores
cor(oly_renorm, pca_oly$scores[, 1])
# correlation and pairs plot between PCA scores and original standardised scores
cor(oly_renorm, pca_oly$scores)
pairs(oly_renorm, pca_oly$scores, pch = 16, cex = 0.5)

# correlation circle
var <- get_pca_var(pca_oly); var
# http://www.sthda.com/english/wiki/principal-component-analysis-in-r-prcomp-vs-princomp-r-software-and-data-mining#graph-of-variables-the-correlation-circle
# Correlation between variables and principal components
var_cor_func <- function(var.loadings, comp.sdev) {
  var.loadings*comp.sdev
}
# Variable correlation/coordinates
loadings <- pca_oly2$rotation # dwitiyo poddhyoti theke
sdev <- pca_oly2$sdev # dwitiyo poddhyoti theke
var.coord <- var.cor <- t(apply(loadings, 1, var_cor_func, sdev))
# Plot the correlation circle
a <- seq(0, 2*pi, length = 100)
plot( cos(a), sin(a), type = 'l', col = "red", xlab = "PC1",  ylab = "PC2")
abline(h = 0, v = 0, lty = 2)
# Add active variables
arrows(0, 0, var.coord[, 1], var.coord[, 2], length = 0.1, angle = 15, code = 2)
# Add labels
text(var.coord, labels = rownames(var.coord), cex = 1, adj = 1)

# biplot
biplot(pca_oly)
abline(h = 0, v = 0, lty = 2)

# screeplot
plot(pca_oly)
screeplot(pca_oly)
