# MCGPULite_v1.5
A Lightweight version of [VICTRE_MCGPU](https://github.com/DIDSR/VICTRE_MCGPU/) (A GPU-Accelerated Monte Carlo X-Ray Transport Simulation Tool).

## MCGPULite_v1.5 vs MCGPULite

Compared to [MCGPULite](https://github.com/SEU-CT-Recon/MCGPULite), MCGPULite_v1.5 introduces several improvements:

- Users can now choose the rotation axis to be the X-axis, Y-axis, or Z-axis, rather than being limited to simple CT trajectory rotations around the Z-axis.
- The initial rotation angle of the first projection image can be determined simply by specifying an angle, instead of calculating the initial incident source position (direction cosines) or modifying the phantom file.
- The offset of the X-ray beam relative to the detector center can be modified.
- There is now an option to select a collimator model.
- There is now an option to select a protective shell/lid model.
- Users can opt to store large voxel phantoms (with more than 2^31 voxels) in memory using a binary tree structure to save memory.
- Material files now allow users to customize density and material numbers.
- The output files no longer include ASCII format files but will save simulation reports for each projection, which can be opened with ImageJ.

## MCGPULite_v1.5 vs VICTRE_MCGPU

Compared to [VICTRE_MCGPU](https://github.com/DIDSR/VICTRE_MCGPU/), MCGPULite_v1.5 has undergone the following reductions and modifications:

- **Makefile Rewrite**: The [Makefile](https://github.com/SEU-CT-Recon/MCGPULite_v1.5/blob/main/Makefile) has been rewritten to support standalone zlib, CUDA, nvcc, and openmpi, eliminating the need for `sudo apt-get`. It has also been synchronized with [MCGPULite](https://github.com/SEU-CT-Recon/MCGPULite).

  - Have CUDA installed correctly.

  - Download zlib and openmpi. Compile them.

    ```sh
    # zlib
    ./configure
    make
    make install prefix=/zlib/install/path
    # openmpi
    ./configure --prefix=/openmpi/install/path
    make
    make install
    ```

  - Modify paths in Makefile according to your machine.

    ```makefile
    # You should modify these according to your machine.
    NVCC = /usr/local/cuda-10.1/bin/nvcc
    CUDA_INCLUDE = /usr/local/cuda-10.1/include/
    CUDA_LIB = /usr/local/cuda-10.1/lib64/
    CUDA_SDK_INCLUDE = /usr/local/cuda-10.0/samples/common/inc/
    CUDA_SDK_LIB = /usr/local/cuda-10.0/samples/common/lib/linux/x86_64/
    OPENMPI_INCLUDE = /home/zhuoxu/app/openmpi-4.1.1/install/include/
    OPENMPI_LIB = /home/zhuoxu/app/openmpi-4.1.1/install/lib/
    ZLIB_INCLUDE = /home/zhuoxu/app/zlib-1.2.11/install/include/
    ZLIB_LIB = /home/zhuoxu/app/zlib-1.2.11/install/lib/
    ```

  - Compile MCGPULite.

    ```sh
    make clean
    make
    ```

  - You can create a symbol link and add it to PATH if you want.

    ```sh
    ln -s MCGPULite_v1.5.x MCGPULite1.5
    
    # vim ~/.bashrc
    export PATH="/path/to/MCGPULite/folder/:$PATH"
    # source ~/.bashrc
    ```

- **Focal Spot Model Removal**: The focal spot model has been removed, and the [MC-GPULite_v1.5_sample.in](https://github.com/SEU-CT-Recon/MCGPULite_v1.5/blob/main/MC-GPULite_v1.5_sample.in) input file no longer requires parameters related to the focal spot:

  ```diff
  #[SECTION SOURCE v.2016-12-02]
  ...
  - 0.0300                 # SOURCE GAUSSIAN FOCAL SPOT FWHM [cm]
  - 0.18                   # 0.18 for DBT, 0 for FFDM [Mackenzie2017]  # ANGULAR BLUR DUE TO MOVEMENT ([exposure_time]*[angular_speed]) [degrees]
  - YES                     # COLLIMATE BEAM TOWARDS POSITIVE AZIMUTHAL (X) ANGLES ONLY? (ie, cone-beam center aligned with chest wall in mammography) [YES/NO]
  ```

- **Detector Model Parameter Removal**: Parameters related to fluorescence escape, charge generation, Swank factor, and electronic noise have been removed from the detector model:

  ```diff
  #[SECTION IMAGE DETECTOR v.2017-06-20]
  ...
  - 12658.0 11223.0 0.596 0.00593  # DETECTOR K-EDGE ENERGY [eV], K-FLUORESCENCE ENERGY [eV], K-FLUORESCENCE YIELD, MFP AT FLUORESCENCE ENERGY [cm]
  - 50.0    0.99                   # EFFECTIVE DETECTOR GAIN, W_+- [eV/ehp], AND SWANK FACTOR (input 0 to report ideal energy fluence)
  - 5200.0                         # ADDITIVE ELECTRONIC NOISE LEVEL (electrons/pixel)
  ```

- **Default Detector Settings**: By default, the detector is not fixed (during multi-angle projections) and both the 0-degree projection and tomographic scan are not simulated simultaneously, to accommodate CBCT scenarios:

  ```diff
  #[SECTION TOMOGRAPHIC TRAJECTORY v.2016-12-02]
  ...
  - YES                             # KEEP DETECTOR FIXED AT 0 DEGREES FOR DBT? [YES/NO]
  - YES                             # SIMULATE BOTH 0 deg PROJECTION AND TOMOGRAPHIC SCAN (WITHOUT GRID) WITH 2/3 TOTAL NUM HIST IN 1st PROJ (eg, DBT+mammo)? [YES/NO]
  ```

- **Dose Information Removal**: Dose information is no longer reported, aligning with [MCGPULite](https://github.com/SEU-CT-Recon/MCGPULite):

  ```diff
  #[SECTION TOMOGRAPHIC TRAJECTORY v.2016-12-02]
  ...
  
  - #[SECTION DOSE DEPOSITION v.2012-12-12]
  ...
  
  #[SECTION VOXELIZED GEOMETRY FILE v.2017-07-26]
  ```

- **Phantom File Format Support Removal**: The phantom file currently **only supports** the header format (**ASCII** format) specified in the documentation, and the binary tree storage format has been temporarily disabled.

  ```diff
  #[SECTION VOXELIZED GEOMETRY FILE v.2017-07-26]
  ...
  - 1280   1950   940              # NUMBER OF VOXELS: INPUT A 0 TO READ ASCII FORMAT WITH HEADER SECTION, RAW VOXELS WILL BE READ OTHERWISE
  - 0.0050 0.0050 0.0050           # VOXEL SIZES [cm]
  - 1 1 1                          # SIZE OF LOW RESOLUTION VOXELS THAT WILL BE DESCRIBED BY A BINARY TREE, GIVEN AS POWERS OF TWO (eg, 2 2 3 = 2^2x2^2x2^3 = 128 input voxels per low res voxel; 0 0 0 disables tree)
  ```
  
  In MCGPU_v1.5b, material densities were fixed to a certain value, which meant that variations in density within the same material in the vox file would become invalid. Therefore, MCGPULite_v1.5 removed this restriction. However, this change appears to affect the functionality of the binary tree storage, so the binary tree storage feature has been temporarily disabled.
  
- **Material File Customization Removal**: Material files no longer allow users to customize densities and material IDs, as it was found to be incompatible with ASCII format voxel files.

  ```diff
  #[SECTION MATERIAL FILE LIST v.2020-03-03]   
  -#  -- Input material file names first, then material density after keyword 'density=' (optional if using nominal density), then comma-separated list of voxel ID numbers after keyword 'voxelID=' (empty if material not used).
  - air__5-120keV.mcgpu                  density=0.0012   voxelId=0        
  adipose__5-120keV.mcgpu    
  ```
  
- **Output File Content**: The output files include three slices: total signal, primary signal, and scatter signal, rather than just the total and primary signals, aligning with [MCGPULite](https://github.com/SEU-CT-Recon/MCGPULite).

  

 Now you can run it like this **on one GPU**:

  ```sh
  # .in file. Specify which CUDA GPU to run on here.
  3              # GPU NUMBER TO USE WHEN MPI IS NOT USED, OR TO BE AVOIDED IN MPI RUNS
  
  # Command line. Just as it should be.
  MCGPULite1.5 ./<input_file>.in
  ```

  Or like this **on multiple GPUs**:

  ```sh
  # .in file. Use -1 always here.
  -1              # GPU NUMBER TO USE WHEN MPI IS NOT USED, OR TO BE AVOIDED IN MPI RUNS
  
  # Command line. Use CUDA_VISIBLE_DEVICES to specify GPUs, and pass GPU counts to -np.
  mpirun -x CUDA_VISIBLE_DEVICES=0,1,2,3 -np 4 MCGPULite1.5 ./<input_file>.in
  ```

  Through experiments, **I don't recommend you to use multiple GPUs if your TOTAL NUMBER OF HISTORIES is less than 1e10** because of the distribution overhead. Otherwise, I achieve a time cutdown by 66% with 1e11 histories.

- The terminal outputs talk less.
