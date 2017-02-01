rm(list = ls())
setwd('C:/Users/USER/Downloads/DSTI/Machine Learning')
getwd()

# Beispiel of creating a simulation fn from an exponential density
# and compare with a simulated exponential density drawn with R-fn dexp()
simuexp <- function(n, lambda) {
    u = runif(n)
    simuexp = -1/lambda*log(u)
}
a <- simuexp(n = 5000, lambda = 2)

x <- seq(0, 4, 0.01)
y <- dexp(x, 2)
hist(a, breaks = 20, freq = FALSE)
lines(x, y, col = 'red')

# Één simulatië voorbeeld van de Laplace fn
simulaplace <- function(n) {
    epsilon <- 2*rbinom(n, 1, 0.5) - 1 # discrete values obtained: {-1 & 1}
    z <- rexp(n, 1)
    simulaplace <- epsilon*z
}
a <- simulaplace(5000)

x <- seq(-10, 10, 0.01)
y <- (1/2)*exp(-abs(x))
hist(a, freq = FALSE, breaks = c(seq(-10, -0.5, 0.5), seq(-0.5, 0.5, 0.10), seq(0.5, 10, 0.5)), ylim = c(0, 0.6), xlim = c(-10, 10), col = 'green')
lines(x, y, col = 'red', lwd = '3')

# HW3: accept-Reject algorithm of a standard Gaussian density
# with a double exponential (Laplace) ["envelopping"] density
# c <- sqrt(2*exp(1)/pi) => 1.31
x <- seq(-10, 10, 0.01)
y1 <- dnorm(x)
y2 <- (1/2)*exp(-abs(x))*sqrt(2*exp(1)/pi)
plot(x, y1, col = 'blue', xlim = c(-10, 10), ylim = c(0, 1), type = 'l', lwd = '3')
lines(x, y2, col = 'red', lwd = '3')
title('Target density Gaussian, proposal density Laplace (double exp.)')

rejectnorm <- function(n, c) {
    i <- 0 # count total no. of simulations
    a <- c() # count of no. of accepted
    while (length(a) < n) {
        i <- i + 1
        z <- simulaplace(1)
        u <- runif(1)
        f <- dnorm(z)
        g <- 1/2*(exp(-abs(z)))
        if(u*c*g < f) {a <- c(a, z)}
    }
    rejectnorm <- list(simval = a, totnsim = i)
}
t <- rejectnorm(n = 5000, c = sqrt(2*exp(1)/pi))
t[[2]]

hist(t[[1]], breaks = 50, col = 'yellow', freq = FALSE)
x <- seq(-5, 5, 0.01)
lines(x, dnorm(x), col = 'red', lwd = '3')





# HW4
# load libraries
require(dplyr); require(car)

# OECD data: read data and basic infos
oecd <- read.table('oecd.txt', header = TRUE, sep = '')
colnames(oecd); rownames(oecd); summary(oecd); dim(oecd); length(oecd)

# collapse continuous variables into respective means by country (library: dplyr)
oecd2 <- group_by(oecd, country)
oecd3 <- summarise(oecd2,
                   birthRate = mean(birth_rate, na.rm = TRUE),
                   unemploy = mean(unemployement_rate, na.rm = TRUE),
                   prWorkPerc = mean(percentage_of_worker_primary_sector, na.rm = TRUE),
                   secWorkPerc = mean(percentage_of_worker_secondary_sector, na.rm = TRUE),
                   GDP = mean(GDP, na.rm = TRUE),
                   asset = mean(asset, na.rm = TRUE),
                   priceIncr = mean(price_increase, na.rm = TRUE),
                   income = mean(income, na.rm = TRUE),
                   infantMort = mean(infant_mortality, na.rm = TRUE),
                   animalProteinDiet = mean(consumption_of_animal_protein, na.rm = TRUE),
                   energyConsum = mean(energy_consumption, na.rm = TRUE))

# plot kernel densities
par(mfrow = c(3, 4), oma = c(0, 0, 3, 0))
plot(density(oecd3$birthRate), lwd = '3', col = 'red', main = 'Birth rate', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$unemploy), lwd = '3', col = 'blue', main = 'Unemployment', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$prWorkPerc), lwd = '3', col = 'green', main = '% worker (pr. sector)', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$secWorkPerc), lwd = '3', col = 'yellow', main = '% worker (sec. sector)', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$GDP), lwd = '3', col = 'black', main = 'GDP', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$asset), lwd = '3', col = 'brown', main = 'Asset', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$priceIncr), lwd = '3', col = 'cyan', main = 'Price rise', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$income), lwd = '3', col = 'magenta', main = 'Income', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$infantMort), lwd = '3', col = 'grey', main = 'Infant mortality', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$animalProteinDiet), lwd = '3', col = 'dark green', main = 'Animal protein diet', xlab = '', cex.main = 2, cex.lab = 1.5)
plot(density(oecd3$energyConsum), lwd = '3', col = 'dark blue', main = 'Energy', xlab = '', cex.main = 2, cex.lab = 1.5)
mtext('Kernel density estimates', cex = 1.5, outer = TRUE, font = 2)

# plot scatterplot matrix (library: car)
scatterplotMatrix(~birthRate + unemploy + prWorkPerc + secWorkPerc + GDP + asset +
                   priceIncr + income + infantMort + animalProteinDiet + energyConsum,
                   data = oecd3, main = "Pairs plot", pch = 16, cex = 0.4,
                   diagonal = 'histogram', upper.panel = NULL, cex.labels = 1.5,
                   font.labels = 2)

# tests of Normality (with Shapiro-Wilk's test)
shapiro.test(oecd3$birthRate)
shapiro.test(oecd3$unemploy)
shapiro.test(oecd3$prWorkPerc)
shapiro.test(oecd3$secWorkPerc)
shapiro.test(oecd3$GDP)
shapiro.test(oecd3$asset)
shapiro.test(oecd3$priceIncr)
shapiro.test(oecd3$income)
shapiro.test(oecd3$infantMort)
shapiro.test(oecd3$animalProteinDiet)
shapiro.test(oecd3$energyConsum)

# outlier's test
outlierTest(lm(oecd3$birthRate ~ 1))
outlierTest(lm(oecd3$unemploy ~ 1))
outlierTest(lm(oecd3$prWorkPerc ~ 1))
outlierTest(lm(oecd3$secWorkPerc ~ 1))
outlierTest(lm(oecd3$GDP ~ 1))
outlierTest(lm(oecd3$asset ~ 1))
outlierTest(lm(oecd3$priceIncr ~ 1))
outlierTest(lm(oecd3$income ~ 1))
outlierTest(lm(oecd3$infantMort ~ 1))
outlierTest(lm(oecd3$animalProteinDiet ~ 1))
outlierTest(lm(oecd3$energyConsum ~ 1))
