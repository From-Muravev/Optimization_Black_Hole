# Optimization Black Hole

This repository presents the implementation of a genetic algorithm for optimizing a metamaterial with a Christmas tree structure, the physics of which is based on the phenomenon of an acoustic black hole.

**Current status**: Refactoring 🔨

---
Program structure:
 - optimization_res.m
 This is the file that is responsible for running the entire program.
 - Create_initial_gen.m
 In this file, the first generation is created, which will be changed in the future
 - Cost_func.m
 This file implements a cost function by which we will determine the course of evolution (the most favorable case has a low cost). In our case, the average value of the pressure coefficient at the point behind the structure
 - Ruletka.m
 This file implements the algorithm for choosing parents - "roulette wheel"
 - Crossover.m
 This file implements the receipt of new chromosomes through crossover (random crossing of parental genes)
 - Mutation.m
 This file implements the process of random mutations of chromosomes
 - P_calc.m
 This file maps the cost function to the corresponding probability. The total probability does not exceed one
 - Get_res_table.m
 This file reads a table of pressure coefficient values at a certain point
 - Export_3D.m
 This file implements the receipt of a 3D structure in the form of a .mph file for its further printing
 - Auxiliary functions are also present (corresponding folder)
---
The details of each part of the program are described in files before the code.
