# A* Galaxy Generator
Fully playable in web browser project made inside Godot Engine.
[Link to the web project](https://pick65.github.io/AStar-Galaxy-Generator/)

**Bellow I will briefly explain how the code works.**

## Creating galaxies

At the beginning galaxies are generated in the grid, then for every
one of them a unique random "x" and "y" cordinate offset is generated.
To prevent the galaxies from overlapping, a bounding box test is done
for every single one of them, and if any overlaps are found, one of the
objects is deleted.

## Creating connections

To create connections a A* algorithm is used. Thanks to Godot Engine
having it built in, I could skip having to write it myself.
Bellow I have put a simple image that demonstrates how the algorithm
connects the galaxies.
<p align="center">
  <img src="ConnectionAlgorithm.png" width="400" alt="Connection Algorith Image">
</p>

(**green**) Create a random path between two points.<br />
(**light green**) If any of the two previous points in the path has shorter distance to the next one, pick one of them, instead of the one on the front.<br />
(**blue**) Connect any points with no connections to two closest ones.<br />
(**red**) Connect points that are really close to each other.
