# minisat_gpu
GPU acceleration of BCP implemented using watched literals.

Dependencies:
1. Latest CUDA framework on an Ubuntu system.
2. Nvidia graphics card.

Build instructions:
1. g++ -c Options.cc -o Options.o
2. g++ -c System.cc -o System.o
3. nvcc -arch=sm_50 --ptxas-options=-v -c Solver.cu -o Solver.o -L/usr/local/cuda/lib64 -lcudart
4. g++ Main.cc Options.o System.o Solver.o -o <Executable_name> -L/usr/local/cuda/lib64 -lcudart -lz

Testing:
Run command "<Executable_name> <example.cnf>"
