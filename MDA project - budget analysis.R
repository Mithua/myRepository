######################################
#  MDA budget data analysis project  #
######################################

# load libraries
library(data.table)
library(FactoMineR)
library(ggplot2)
library(factoextra)
library(reshape2) # <- function(melt)-er jonnye
library(dplyr)
library(tidyr)
library(rpart)

# working directory
setwd('C:\\Users\\Soutrik\\Downloads')
getwd()
dir()

# load dataset
budget <- read.table('Budget.txt', sep = ',', header = FALSE)

# colnames jora - data.table() poddhyotite
setnames(budget, old = c("V1", "V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12"), new = c("year", "auth", "agri", "comp", "work", "accom", "educ", "social", "veterns", "defns", "debt", "misc"))

# bochhor take string_e poriborton kora ebong categorise kora
budget$year_str <- as.character(budget$year)
budget$year_cat <- ifelse(budget$year == 1872 | budget$year == 1880 | budget$year == 1890 | budget$year == 1900 | budget$year == 1903 | budget$year == 1906 | budget$year == 1909 | budget$year == 1912, "1872-1912",
                     ifelse(budget$year == 1920 | budget$year == 1923 | budget$year == 1926 | budget$year == 1929 | budget$year == 1932 | budget$year == 1935 | budget$year == 1938, "1920-1938",
                       ifelse(budget$year == 1947 | budget$year == 1950 | budget$year == 1953 | budget$year == 1956 | budget$year == 1959 | budget$year == 1962 | budget$year == 1965 | budget$year == 1968 | budget$year == 1971, "1947-1971", NA)))

# descriptive table
budget.summary <- budget %>%
  select(auth, agri, comp, work, accom, educ, social, veterns, defns, debt, misc) %>%
  summarise_each(funs(Mean = mean,
                      SD = sd,
                      Median = median,
                      IQR = IQR,
                      Min = min,
                      Max = max))
budget.tidy <- budget.summary %>% gather(stat, val) %>%
  separate(stat, into = c("Variable", "stat"), sep = "_") %>%
  spread(stat, val) %>%  select(Variable, Mean, SD, Median, IQR, Min, Max)
print(budget.tidy, digits = 3)
# write.table(x = budget.tidy, file = 'budget.tidy.csv', sep = ",", row.names = FALSE, quote = FALSE)
### er pore file take muchhe debe kaaj hoye gele

# tracking graph after corrected standardisation
budget_std <- as.data.frame(scale(budget[, 2:12], center = TRUE, scale = TRUE)*sqrt(23/24))
budget_std <- cbind.data.frame("year" = budget$year, budget_std)
budget_std_long <- melt(budget_std, id = "year") # library{reshape2}
ggplot(data = budget_std_long, aes(x = year, y = value, colour = variable)) + geom_line()

# descriptive table bij nieuwe jaar groep (acc. to the clusters definition obtained later)
budget_long <- melt(budget[, c(1:12)], id = "year") # library{reshape2}
budget_long$year_cat <- ifelse(budget_long$year == 1872 | budget_long$year == 1880 | budget_long$year == 1890 | budget_long$year == 1900 | budget_long$year == 1903 | budget_long$year == 1906 | budget_long$year == 1909 | budget_long$year == 1912, "1872-1912",
                          ifelse(budget_long$year == 1920 | budget_long$year == 1923 | budget_long$year == 1926 | budget_long$year == 1929 | budget_long$year == 1932 | budget_long$year == 1935 | budget_long$year == 1938, "1920-1938",
                             ifelse(budget_long$year == 1947 | budget_long$year == 1950 | budget_long$year == 1953, "1947-1953",
                               ifelse(budget_long$year == 1956 | budget_long$year == 1959 | budget_long$year == 1962 | budget_long$year == 1965 | budget_long$year == 1968 | budget_long$year == 1971, "1956-1971", NA))))

budget_long.summary <- budget_long %>%
  group_by(variable, year_cat) %>%
  select(year_cat, variable, value) %>%
  summarise_each(funs(N = n(),
                      Mean = mean,
                      SD = sd,
                      Median = median,
                      IQR = IQR,
                      Min = min,
                      Max = max))
print(budget_long.summary, digits = 3)
# write.table(x = budget_long.summary, file = 'budget_long.summary.csv', sep = ",", row.names = FALSE, quote = FALSE)
### er pore file take muchhe debe kaaj hoye gele

# PCA
# reload, row.names bodlano budget2 dataset
budget2 <- read.table('Budget.txt', sep = ',', header = FALSE, row.names = 1)
setnames(budget2, old = c("V2", "V3", "V4", "V5", "V6", "V7", "V8", "V9", "V10", "V11", "V12"), new = c("auth", "agri", "comp", "work", "accom", "educ", "social", "veterns", "defns", "debt", "misc"))

budget2.pca <- PCA(budget2) # + associated graphs
cor_fac12_vars <- round(budget2.pca$var$coord[, 1:2], 2)
  cor_fac34_vars <- round(budget2.pca$var$coord[, 3:4], 2) # not shown
  lapply(dimdesc(budget2.pca), lapply, round, 2) # sig. cor.
var_decomp <- round(budget2.pca$eig, 2) # sum(budget2.pca$eig[, 1]) = 11
dist_ind_centre <- as.matrix(round(budget2.pca$ind$dist, 2))
contrib_ind <- round(budget2.pca$ind$contrib[, 1:2], 2) # sum(budget2.pca$var$contrib[, 1]), sum(budget2.pca$var$contrib[, 2]) = 100%
contrib_var <- round(budget2.pca$var$contrib[, 1:2], 2) # sum(budget2.pca$var$contrib[, 3]), sum(budget2.pca$var$contrib[, 4]) = 100%

# biplot - error dyay PCA() function_er sathe
budget2bis.pca <- princomp(budget2)
biplot(budget2bis.pca)

# cluster analysis from PCA
budget2.hcpc <- HCPC(budget2.pca) # + associated graphs

# CART from cluster analysis
Y <- as.factor(budget2.hcpc$data.clust$clust)
T = rpart(Y ~ ., data = budget2, control = rpart.control(minsplit = 2, cp = 10^(-15)))
plot(T); text(T); T
hY = predict(T, type = 'class'); hY
error = (1/nrow(iris))*sum(Y != hY); error
var_imp <- as.matrix(T$variable.importance)
