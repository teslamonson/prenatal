### August 18th 2022 - Supplementary code for performing main analyses in "Teeth, prenatal growth rates, and the evolution of human-like pregnancy in later Homo" (Monson et al. 2022, PNAS)

## Clear current working environment and set working directory:

rm(list=ls())
setwd()

## Load required packages (note that dplyr can conflict with the phylogenetics packages with select(), so dplyr commands are specified with dplyr:: to avoid this when necessary):

library(dplyr)
library(ggplot2)
library(ape)
library(phytools)
library(caper)

## The following code demonstrates how to perform PGLS tests between different variables (e.g. PGR and ECV). PGLS takes into account phylogenetic non-independence between data points (in this case, mean values of different species), and thus requires a phylogeny to be loaded.

## Significant results from summary() on fitted PGLS models gives statistical support to make predictions based on new inputted values (in this case, from fossils), because PGLS tests whether or not there is a real, phylogenetically-controlled signal in the data.

## After loading in the ECV and PGR values by species (PGLS data.csv), create a new dataset with only these three columns:

ECV.PGR <- dat %>%
  dplyr::select("Species","logECV","PGR")

## Import phylogenetic tree (PGLS phylogeny.nex), replace underscores with spaces, and select consensus tree:
tree1<-read.tree("PGLS phylogeny.nex")
tree1[[1]]$tip.label <- sub("_", " ", tree1[[1]]$tip.label)
tree.c <- tree1[[1]] 

## Drop tips that aren't in the dataset and plot the tree to confirm all taxa are represented:
tree.d <- drop.tip(tree1[[1]], setdiff(tree1[[1]]$tip.label, ECV.PGR$Species))

plot(tree.d) # looks good

## Merge phylogeny with this data:

## Note that Trachypithecus obscuras is in our original data - its synonym with this phylogeny is T. phayrei

primate.ecv.pgr <- comparative.data(tree.d, ECV.PGR, Species)

## Quick visualization of the correlation:

ggplot(man, aes(logECV, PGR)) +
  geom_point()

## PGLS test for linear relationship:

model.pgls.ecv.pgr<-pgls(PGR ~ logECV, data = primate.ecv.pgr, lambda = 'ML', kappa = 'ML', delta = 'ML')
summary(model.pgls.ecv.pgr) # highly significant

## Now we can check residuals to confirm model is a good fit of the data:
plot(fitted(model.pgls.ecv.pgr),residuals(model.pgls.ecv.pgr), 
     xlab = "fitted values",
     ylab = "residuals", 
     main = "PGLS: PGR ~ log ECV") # all good, there is no clear pattern

## Repeating these steps allows one to test the other relationships between PGR, XMMC, DMMC, and ECV

## Next, the following code is used to make predictions for fossil unknowns:

## With all of the the extant and fossil data loaded (Extant and fossil data.csv), separate it out into only values for each category:

extants <- dat %>%
  filter(GeologicAge == "Extant")

fossils <- dat %>%
  filter(GeologicAge == "Fossil")

## The following example shows how to predict prenatal growth rate from ECV for fossil unknowns:

## Quick visualization of this relationship for reference:

ggplot(extants, aes(logECV, PGR)) +
  geom_point()

# Make a dataframe of just the fossil logECV values to predict with this model:
fossilpred.ecv <- fossils %>%
  dplyr::select(logECV)

# Predictions:
fossilpreds.ecv <- predict(model.pgls.ecv.pgr, fossilpred.ecv)

# Finally, make this a dataframe to merge with original data, eg:
asd <- as.data.frame(fossilpreds.ecv)

# Repeating these steps allows one to make predictions from other models



