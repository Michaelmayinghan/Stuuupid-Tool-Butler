# Stuuupid-Tool-Butler
For detailed algorithm analysis and results, please refer to the [Technical Report](./Y1T2_DSA_Project.pdf)
🤖 The Robot Guide: Navigation & Motion Analysis
This project is a comprehensive implementation of Spatial Data Structures and Pathfinding Algorithms designed for autonomous robot navigation. It also includes a signal processing pipeline to classify robot movement patterns based on sensor data.

🎯 Key Features
1. Spatial Search & Pathfinding

KD-Tree Implementation: Built a 2D KD-Tree from scratch to optimize nearest neighbor searches, reducing query complexity from linear to O(logn).

Optimized Routing: Implemented and benchmarked BFS and Dijkstra’s algorithm, with a specific focus on performance gains using a Min-Heap (Priority Queue).

2. Motion Pattern Recognition (AI & Signal Processing)

Signal Smoothing: Utilized the Savitzky-Golay filter to process raw kinematic data, effectively removing sensor noise and unrealistic spikes.

State Classification: Developed a threshold-based classifier using velocity magnitude and turning rates to identify motion states such as Accelerating, Turning, Fast, and Stop.

🛠️ Tech Stack
Algorithms: KD-Tree, Dijkstra, BFS, Min-Heap.

Tools: MATLAB, Python (Pandas/Matplotlib) for data analysis and visualization.

📂 Repository Structure
