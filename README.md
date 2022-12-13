# ImageReconstruction

This repository is an implementation of the Lin-Kernighan heuristic to solve the travelling salesman problem (TSP), which is a problem that belongs to the NP-complete class.

We can apply the logic behind the TSP to reconstruct shredded images, i.e., images that have been manipulated and hence present a "fuzzy" appearance. In other words, we have an image as follows

### INSERT EXAMPLE IMAGE

and want to get the original image as follows

### INSERT EXAMPLE RECONSTRUCTED IMAGE

Thus, we can solve this problem by solving a TSP where each node is a column/row of the image shredded and the distance between them is the dissimilarity measure according to their pixel differences, for example. Here, it is worth noting that the measure has a big impact on the result.

To fit this problem into a TSP instance, we use an augmented graph using a "fake" node with zero distance to each other node (that represents the columns/rows in the shredded image). In this regard, we aim to find a tour in this augmented graph and traverse it to reorder the columns such that an original-close image is obtained. Although we get a "good" tour, we can get reversed images depending on which traversing is chosen, i.e., preorder or postorder. Seemingly, both are interpreted as correct since we are just getting the same image.
