# Makefile for MCGPULite_v1.5
.SUFFIXES: .cu .o

PROG = MCGPULite_v1.5.x

SHELL = /bin/sh
RM = /bin/rm -vf

# You should modify these according to your machine.
NVCC = /home/kanshengqi/cuda-11.3/bin/nvcc
CUDA_INCLUDE = /home/kanshengqi/cuda-11.3/include/
CUDA_LIB = /home/kanshengqi/cuda-11.3/lib64/
CUDA_SDK_INCLUDE = /home/kanshengqi/cuda-11.3/samples/common/inc/
CUDA_SDK_LIB = /home/kanshengqi/cuda-11.3/samples/common/lib/linux/x86_64/
OPENMPI_INCLUDE = /home/kanshengqi/software/openmpi-4.1.1/install/include/
OPENMPI_LIB = /home/kanshengqi/software/openmpi-4.1.1/install/lib/
ZLIB_INCLUDE = /home/kanshengqi/software/zlib-1.2.13/install/include/
ZLIB_LIB = /home/kanshengqi/software/zlib-1.2.13/install/lib/

CFLAGS = -O3 -use_fast_math -m64 -DUSING_CUDA -DUSING_MPI \
	-I./ -I$(CUDA_INCLUDE) -I$(CUDA_SDK_INCLUDE) -I$(OPENMPI_INCLUDE) -I$(ZLIB_INCLUDE) \
	-L$(CUDA_SDK_LIB) -L$(CUDA_LIB) -lcudart \
	-lm \
	-L$(ZLIB_LIB) -lz \
	-L$(OPENMPI_LIB) -lmpi \
	--ptxas-options=-v

SRCS = MC-GPU_v1.5b.cu

default: $(PROG)
$(PROG):
	$(NVCC) $(CFLAGS) $(SRCS) -o $(PROG)

clean:
	$(RM) $(PROG)
