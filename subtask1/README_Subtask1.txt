Subtask 1 MATLAB interface
==========================

Main entry point:
    run_subtask1_interface

What this version fixes compared with the earlier draft:
1. Reuses the repository's existing QEOP background map image
   (occupancyMap/SatelliteImageNoLabel.png) instead of showing only the binary grid.
2. Overlays the saved occupancy grid on top of the real map.
3. Includes all required complexity discussion in the UI:
   - linked-list lookup O(n)
   - KD-tree average O(log n), worst O(n)
   - BFS O(V+E)
   - Dijkstra without priority queue O(V^2 + E)
   - Dijkstra with binary-heap priority queue O((V+E)logV)
4. Includes empirical timing benchmarks in a table.
5. Includes both Dijkstra variants in the path-search section.
6. Provides a pool of 10 customizable queries.

Query coverage:
- Path from A to B
- Distance from A to B
- k closest key points from A
- 2 closest key points to waiting area 1
- 2 closest key points to waiting area 2
- Closest key point to A
- Nearest waiting point to A
- Full route: nearest waiting -> A -> B -> nearest waiting
- Compare BFS / Dijkstra / Dijkstra+PQ
- List all key points sorted by distance from A

Notes:
- This code uses the existing extractedPoints.m file so the exact project points stay aligned with the repo.
- This code uses the existing adjacency-list graph for consistency with the project.
- Dijkstra+PQ is implemented with a binary heap in dijkstra_heap.m rather than a linear search over a simple array.
