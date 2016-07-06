NAME = gfc

#ADJUST THE FOLLOWING ACCORDINGLY:
#Cross-compiling wrappers: [WRAP|NOWRAP]:
export WRAP ?= NOWRAP
#Compiler: [GNU|PGI|INTEL|CRAY|IBM]:
export TOOLKIT ?= GNU
#Optimization: [DEV|OPT]:
export BUILD_TYPE ?= DEV
#MPI Library: [MPICH|OPENMPI|NONE]:
export MPILIB ?= MPICH
#BLAS: [ATLAS|MKL|ACML]:
export BLASLIB ?= ATLAS
#Operating system: [LINUX|NO_LINUX]:
export EXA_OS ?= LINUX

#SET YOUR LOCAL PATHS (for unwrapped build):
# MPI path:
export PATH_MPICH ?= /usr/local/mpich3.2
export PATH_OPENMPI ?= /usr/local/openmpi1.10.1
# BLAS lib path:
export PATH_BLAS_ATLAS ?= /usr/lib
export PATH_BLAS_MKL ?= /ccs/compilers/intel/rh6-x86_64/16.0.0/compilers_and_libraries/linux/mkl/lib
export PATH_BLAS_ACML ?= /usr/lib
PATH_BLAS = $(PATH_BLAS_$(BLASLIB))

#YOU ARE DONE!


#=================
#Fortran compiler:
FC_GNU = gfortran
FC_PGI = pgf90
FC_INTEL = ifort
FC_CRAY = ftn
FC_IBM = xlf2008_r
FC_MPICH = $(PATH_MPICH)/bin/mpif90
FC_OPENMPI = $(PATH_OPENMPI)/bin/mpifort
FC_NONE = $(FC_$(TOOLKIT))
FC_NOWRAP = $(FC_$(MPILIB))
FC_WRAP = ftn
FCOMP = $(FC_$(WRAP))
#C compiler:
CC_GNU = gcc
CC_PGI = pgcc
CC_INTEL = icc
CC_CRAY = cc
CC_IBM = xlc_r
CC_MPICH = $(PATH_MPICH)/bin/mpicc
CC_OPENMPI = $(PATH_OPENMPI)/bin/mpicc
CC_NONE = $(CC_$(TOOLKIT))
CC_NOWRAP = $(CC_$(MPILIB))
CC_WRAP = cc
CCOMP = $(CC_$(WRAP))
#C++ compiler:
CPP_GNU = g++
CPP_PGI = pgc++
CPP_INTEL = icc
CPP_CRAY = CC
CPP_IBM = xlC_r
CPP_MPICH = $(PATH_MPICH)/bin/mpic++
CPP_OPENMPI = $(PATH_OPENMPI)/bin/mpic++
CPP_NONE = $(CPP_$(TOOLKIT))
CPP_NOWRAP = $(CPP_$(MPILIB))
CPP_WRAP = CC
CPPCOMP = $(CPP_$(WRAP))
#CUDA compiler:
CUDA_COMP = nvcc

#COMPILER INCLUDES:
INC_GNU = -I.
INC_PGI = -I.
INC_INTEL = -I.
INC_CRAY = -I.
INC_NOWRAP = $(INC_$(TOOLKIT))
INC_WRAP = -I.
INC = $(INC_$(WRAP))

#COMPILER LIBS:
LIB_GNU = -L.
LIB_PGI = -L.
LIB_INTEL = -L.
LIB_CRAY = -L.
LIB_NOWRAP = $(LIB_$(TOOLKIT))
LIB_WRAP = -L.
ifeq ($(TOOLKIT),PGI)
 LIB = $(LIB_$(WRAP))
else
 LIB = $(LIB_$(WRAP)) -lstdc++
endif

#MPI INCLUDES:
MPI_INC_MPICH = -I$(PATH_MPICH)/include
MPI_INC_OPENMPI = -I$(PATH_OPENMPI)/include
MPI_INC_NONE = -I.
MPI_INC_NOWRAP = $(MPI_INC_$(MPILIB))
MPI_INC_WRAP = -I.
MPI_INC = $(MPI_INC_$(WRAP))

#MPI LIBS:
MPI_LINK_MPICH = -L$(PATH_MPICH)/lib
MPI_LINK_OPENMPI = -L$(PATH_OPENMPI)/lib
MPI_LINK_NONE = -L.
MPI_LINK_NOWRAP = $(MPI_LINK_$(MPILIB))
MPI_LINK_WRAP = -L.
MPI_LINK = $(MPI_LINK_$(WRAP))

#LINEAR ALGEBRA FLAGS:
LA_LINK_ATLAS = -L$(PATH_BLAS) -lblas -llapack
LA_LINK_MKL = -L$(PATH_BLAS) -lmkl_intel_lp64 -lmkl_core -lmkl_intel_thread -lpthread -lm -ldl
LA_LINK_ACML = -L$(PATH_BLAS) -lacml_mp
LA_LINK_WRAP = -L.
LA_LINK_NOWRAP = $(LA_LINK_$(BLASLIB))
LA_LINK = $(LA_LINK_$(WRAP))

#CUDA INCLUDES:
CUDA_INC_CUDA = -I$(PATH_CUDA)/include
CUDA_INC_NOCUDA = -I.
CUDA_INC_NOWRAP = $(CUDA_INC_$(GPU_CUDA))
CUDA_INC_WRAP = -I.
CUDA_INC = $(CUDA_INC_$(WRAP))

#CUDA LIBS:
CUDA_LINK_NOWRAP = -L$(PATH_CUDA)/lib64 -lcudart -lcublas
CUDA_LINK_WRAP = -lcudart -lcublas
CUDA_LINK_CUDA = $(CUDA_LINK_$(WRAP))
CUDA_LINK_NOCUDA = -L.
CUDA_LINK = $(CUDA_LINK_$(GPU_CUDA))

#CUDA FLAGS:
CUDA_HOST_NOWRAP = --compiler-bindir /usr/bin
CUDA_HOST_WRAP = -I.
CUDA_HOST = $(CUDA_HOST_$(WRAP))
CUDA_FLAGS_DEV = --compile -arch=sm_35 -g -G -D CUDA_ARCH=350 -D DEBUG_GPU
CUDA_FLAGS_OPT = --compile -arch=sm_35 -O3 -D CUDA_ARCH=350
CUDA_FLAGS_CUDA = $(CUDA_HOST) $(CUDA_FLAGS_$(BUILD_TYPE))
CUDA_FLAGS_NOCUDA = -I.
CUDA_FLAGS = $(CUDA_FLAGS_$(GPU_CUDA)) -D$(EXA_OS)

#Accelerator support:
NO_ACCEL_CUDA = -D NO_AMD -D NO_PHI -D CUDA_ARCH=350
NO_ACCEL_NOCUDA = -D NO_AMD -D NO_PHI -D NO_GPU
NO_ACCEL = $(NO_ACCEL_$(GPU_CUDA))

#C FLAGS:
CFLAGS_DEV = -c -g $(NO_ACCEL)
CFLAGS_OPT = -c -O3 $(NO_ACCEL)
CFLAGS = $(CFLAGS_$(BUILD_TYPE)) -D$(EXA_OS)

#FORTRAN FLAGS:
FFLAGS_INTEL_DEV = -c -g -fpp -vec-threshold4 -qopenmp -mkl=parallel $(NO_ACCEL)
#FFLAGS_INTEL_DEV = -c -g -fpp -vec-threshold4 -openmp $(NO_ACCEL)
FFLAGS_INTEL_OPT = -c -O3 -fpp -vec-threshold4 -qopenmp -mkl=parallel $(NO_ACCEL)
#FFLAGS_INTEL_OPT = -c -O3 -fpp -vec-threshold4 -openmp $(NO_ACCEL)
FFLAGS_CRAY_DEV = -c -g $(NO_ACCEL)
FFLAGS_CRAY_OPT = -c -O3 $(NO_ACCEL)
FFLAGS_GNU_DEV = -c -fopenmp -fbacktrace -fcheck=bounds -fcheck=array-temps -fcheck=pointer -g $(NO_ACCEL)
FFLAGS_GNU_OPT = -c -fopenmp -O3 $(NO_ACCEL)
FFLAGS_PGI_DEV = -c -mp -Mcache_align -Mbounds -Mchkptr -Mstandard -g $(NO_ACCEL)
FFLAGS_PGI_OPT = -c -mp -Mcache_align -Mstandard -O3 $(NO_ACCEL)
FFLAGS_IBM_DEV = -c -qsmp=omp $(NO_ACCEL)
FFLAGS_IBM_OPT = -c -qsmp=omp -O3 $(NO_ACCEL)
FFLAGS = $(FFLAGS_$(TOOLKIT)_$(BUILD_TYPE)) -D$(EXA_OS)

#THREADS:
LTHREAD_GNU   = -lgomp
LTHREAD_PGI   = -lpthread
LTHREAD_INTEL = -liomp5
LTHREAD_CRAY  = -L.
LTHREAD_IBM   = -L.
LTHREAD = $(LTHREAD_$(TOOLKIT))

#LINKING:
LFLAGS = $(LIB) $(LTHREAD) $(MPI_LINK) $(LA_LINK) $(CUDA_LINK)

OBJS =  ./OBJ/dil_basic.o ./OBJ/multords.o ./OBJ/timers.o ./OBJ/gfc_base.o ./OBJ/stack.o ./OBJ/lists.o \
	./OBJ/list.o ./OBJ/dictionary.o ./OBJ/tree.o

$(NAME): lib$(NAME).a ./OBJ/main.o
	$(FCOMP) ./OBJ/main.o lib$(NAME).a $(LFLAGS) -o $(NAME).x

lib$(NAME).a: $(OBJS)
	ar cr lib$(NAME).a $(OBJS)

./OBJ/dil_basic.o: dil_basic.F90
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) dil_basic.F90 -o ./OBJ/dil_basic.o

./OBJ/multords.o: multords.F90
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) multords.F90 -o ./OBJ/multords.o

./OBJ/timers.o: timers.F90
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) timers.F90 -o ./OBJ/timers.o

./OBJ/gfc_base.o: gfc_base.F90 ./OBJ/dil_basic.o ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) gfc_base.F90 -o ./OBJ/gfc_base.o

./OBJ/stack.o: stack.F90 ./OBJ/dil_basic.o ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) stack.F90 -o ./OBJ/stack.o

./OBJ/lists.o: lists.F90 ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) lists.F90 -o ./OBJ/lists.o

./OBJ/list.o: list.F90 ./OBJ/gfc_base.o ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) list.F90 -o ./OBJ/list.o

./OBJ/dictionary.o: dictionary.F90 ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) dictionary.F90 -o ./OBJ/dictionary.o

./OBJ/tree.o: tree.F90 ./OBJ/gfc_base.o ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) tree.F90 -o ./OBJ/tree.o

./OBJ/main.o: main.F90 ./OBJ/dil_basic.o ./OBJ/timers.o
	$(FCOMP) $(INC) $(MPI_INC) $(CUDA_INC) $(FFLAGS) main.F90 -o ./OBJ/main.o


.PHONY: clean
clean:
	rm -f *.x *.a ./OBJ/* *.mod *.modmic *.ptx *.log
