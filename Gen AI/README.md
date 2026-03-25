1. Project Overview

This task demonstrates Speculative Programming in a human-robot interaction scenario. The robot "listens" to a real-time conversation between two indecisive people and dynamically recalculates the optimal navigation path.

Key Features:

GenAI Integration: Uses Ollama (Qwen2.5) to interpret natural language and extract navigation intent.

Real-time Processing: Simulates human speech timestamps to show dynamic path updates.

Algorithm Comparison: Evaluates the efficiency of Linear Linked List (O(n)) vs. KD-Tree (O(logn)) for spatial landmark searching.

2. Environment Setup (Crucial)
 
### How to install and launch LLM (Ollama)

Make sure ur Ollama has downloaded

1. **Download Ollama**: Go [ollama.com](https://ollama.com/) and install
2. **Run**: Open terminal（Terminal）or command（CMD），tap：

```bash
ollama run qwen2.5

Keep it Running: Ensure the Ollama service is active while running the MATLAB script.

3. Algorithm Analysis & Performance

We compared two data structures for searching the 23 topological nodes (Landmarks + Signal Points) in our map.

4. How to Run

Open MATLAB and navigate to the Subtask_2 folder.

Ensure newMapReadings.mat, extractedPoints.m, and parse_dialogue.m are in the same path.

Run subtask2_main.m.

Observe the real-time path updates in the figure window as the dialogue progresses.
