# A* Galaxy Generator
Fully playable in web browser project made inside Godot Engine. <br>

**[Link to the web project](https://sammysame.github.io/AStar-Galaxy-Generator/)** <br>

## Gameplay
Click **REGENERATE** and move around the galaxies by left-clicking on any of them. <br>
The Player “spaceship” will always spawn in the largest galaxy cluster, if more than one present,
and move between points by picking the shortest path. <br>
Play around with different values for the generation. Some things worth checking out are:
<br>  - setting larger **bounding box inflate**, which will make galaxies more spread out
<br>  - changing **amount per row** to less than 3, which will almost always make two separate clusters
<br>  - low **position randomness** will result in more evenly spaced out galaxies <br>


## Creating galaxies

[Source code for the galaxy creator](code/galaxy_view_interface.gd) <br>
At the beginning galaxies are generated in the grid, then for every one of them
a unique random "x" and "y" coordinate offset is applied. To prevent the galaxies
from overlapping, a bounding box test is done for every single one of them,
and if any overlaps are found, one of the objects is deleted.

## Creating connections

[Source code for the connector](code/galaxy_connector.gd) <br>
To create connections, a A* algorithm is used. Thanks to Godot Engine having it built in,
I could skip having to write it myself. Below I have put a simple image that demonstrates
how the algorithm connects the galaxies. 
<p align="center">
  <img src="ConnectionAlgorithm.png" width="400" alt="Connection Algorith Image">
</p>
<p align="center">
  <img src="ConnectionAlgorithmExplanation.png" width="600" alt="Connection Algorith Explanation Image">
</p>
